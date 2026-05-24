import 'package:go_router/go_router.dart';

import '../features/chat/presentation/chat_screen.dart';
import '../features/todos/presentation/todo_screen.dart';
import '../screens/app/app_tab_shell.dart';
import '../screens/app/profile_screen.dart';
import '../features/docs/presentation/docs_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

enum AppRoute {
  home,
  chat,
  docs,
  todos,
  profile,
  login,
  register,
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      name: AppRoute.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: AppRoute.home.name,
      redirect: (context, state) => '/chat',
    ),
    ShellRoute(
      builder: (context, state, child) => AppTabShell(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: '/chat',
          name: AppRoute.chat.name,
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/docs',
          name: AppRoute.docs.name,
          builder: (context, state) => const DocsScreen(),
        ),
        GoRoute(
          path: '/todos',
          name: AppRoute.todos.name,
          builder: (context, state) => const TodoScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: AppRoute.profile.name,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/register',
      name: AppRoute.register.name,
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
