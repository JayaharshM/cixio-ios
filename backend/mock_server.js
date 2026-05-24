const crypto = require('node:crypto');
const http = require('node:http');

const hostname = process.env.HOST || '127.0.0.1';
const port = Number(process.env.PORT || 3000);

const usersByEmail = new Map();

usersByEmail.set('demo@cixio.test', {
  id: crypto.randomUUID(),
  name: 'Demo User',
  email: 'demo@cixio.test',
  password: 'password123',
});

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
  });
  response.end(JSON.stringify(body));
}

function readJson(request) {
  return new Promise((resolve, reject) => {
    let rawBody = '';

    request.on('data', (chunk) => {
      rawBody += chunk;
    });

    request.on('end', () => {
      if (!rawBody) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(rawBody));
      } catch (error) {
        reject(error);
      }
    });

    request.on('error', reject);
  });
}

function createJwtLikeToken(user, type) {
  const header = {
    alg: 'HS256',
    typ: 'JWT',
  };
  const payload = {
    sub: user.id,
    email: user.email,
    name: user.name,
    type,
    iat: Math.floor(Date.now() / 1000),
  };

  return [
    base64Url(JSON.stringify(header)),
    base64Url(JSON.stringify(payload)),
    base64Url(crypto.randomBytes(32)),
  ].join('.');
}

function base64Url(value) {
  return Buffer.from(value).toString('base64url');
}

function publicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
  };
}

function isBlank(value) {
  return typeof value !== 'string' || value.trim().length === 0;
}

async function handleRegister(request, response) {
  const body = await readJson(request);
  const name = typeof body.name === 'string' ? body.name.trim() : '';
  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const password = typeof body.password === 'string' ? body.password : '';

  if (isBlank(name) || isBlank(email) || isBlank(password)) {
    sendJson(response, 400, { message: 'Name, email, and password are required.' });
    return;
  }

  if (password.length < 6) {
    sendJson(response, 400, { message: 'Password must be at least 6 characters.' });
    return;
  }

  if (usersByEmail.has(email)) {
    sendJson(response, 409, { message: 'An account with this email already exists.' });
    return;
  }

  const user = {
    id: crypto.randomUUID(),
    name,
    email,
    password,
  };

  usersByEmail.set(email, user);
  sendJson(response, 201, {
    message: 'Account created.',
    user: publicUser(user),
  });
}

async function handleLogin(request, response) {
  const body = await readJson(request);
  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const password = typeof body.password === 'string' ? body.password : '';
  const user = usersByEmail.get(email);

  if (!user || user.password !== password) {
    sendJson(response, 401, { message: 'Invalid email or password.' });
    return;
  }

  sendJson(response, 200, {
    accessToken: createJwtLikeToken(user, 'access'),
    refreshToken: createJwtLikeToken(user, 'refresh'),
    user: publicUser(user),
  });
}

const server = http.createServer(async (request, response) => {
  try {
    const url = new URL(request.url, `http://${request.headers.host}`);

    if (request.method === 'OPTIONS') {
      sendJson(response, 204, {});
      return;
    }

    if (request.method === 'GET' && url.pathname === '/health') {
      sendJson(response, 200, { ok: true });
      return;
    }

    if (request.method === 'POST' && url.pathname === '/auth/register') {
      await handleRegister(request, response);
      return;
    }

    if (request.method === 'POST' && url.pathname === '/auth/login') {
      await handleLogin(request, response);
      return;
    }

    sendJson(response, 404, { message: 'Route not found.' });
  } catch (error) {
    sendJson(response, 500, { message: 'Mock server error.' });
  }
});

server.listen(port, hostname, () => {
  console.log(`Mock API running at http://${hostname}:${port}`);
  console.log('Seed account: demo@cixio.test / password123');
});
