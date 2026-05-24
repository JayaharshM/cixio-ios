import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import 'auth_api.dart';
import 'auth_chrome.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authApiProvider).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      context.goNamed(AppRoute.home.name);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _messageForError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _messageForError(Object error) {
    if (error is StateError) {
      return error.message;
    }

    if (error is DioException) {
      final Object? data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }

      return 'Login failed. Check your email and password.';
    }

    return 'Login failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Column(
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SmartHubMark(size: 34),
              SizedBox(width: 20),
              Flexible(
                child: Text(
                  'SmartHub',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Sign in to continue',
            style: TextStyle(
              color: authMutedTextColor,
              fontSize: 17,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 28),
            decoration: BoxDecoration(
              color: authPanelColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: authBorderColor),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const <String>[AutofillHints.email],
                    style: const TextStyle(color: Color(0xFF161822)),
                    decoration: _loginInputDecoration('Email Address'),
                    validator: (value) {
                      final String email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'Enter your email.';
                      }
                      if (!email.contains('@')) {
                        return 'Enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isSubmitting,
                    obscureText: _obscurePassword,
                    autofillHints: const <String>[AutofillHints.password],
                    style: const TextStyle(color: Color(0xFF161822)),
                    decoration: _loginInputDecoration(
                      'Password',
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return 'Enter your password.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      if (!_isSubmitting) {
                        _login();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  if (_errorMessage != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _login,
                    child: _isSubmitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 24),
                  const AuthDivider(label: 'or'),
                  const SizedBox(height: 24),
                  const GoogleAuthButton(),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: authMutedTextColor),
                      ),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => context.goNamed(AppRoute.register.name),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Privacy Policy      .      Terms of Service',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF69647D),
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _loginInputDecoration(
    String hintText, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8F8FA),
      hintStyle: const TextStyle(color: Color(0xFF9995AA)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      suffixIcon: suffixIcon,
      suffixIconColor: const Color(0xFFAAA5BA),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFFD8D5E0)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFFD8D5E0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: authPrimaryColor, width: 1.4),
      ),
    );
  }
}
