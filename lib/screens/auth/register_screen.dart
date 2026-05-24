import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import 'auth_api.dart';
import 'auth_chrome.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = 'Please agree to the terms and privacy policy.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authApiProvider).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );
      context.goNamed(AppRoute.login.name);
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

      return 'Registration failed. Please check your details.';
    }

    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 32),
        decoration: BoxDecoration(
          color: authRegisterPanelColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: authRegisterBorderColor),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SmartHubMark(size: 26),
                  SizedBox(width: 12),
                  Text(
                    'SmartHub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Create your premium account to get\nstarted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: authMutedTextColor,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.words,
                autofillHints: const <String>[AutofillHints.name],
                decoration: const InputDecoration(hintText: 'Full Name'),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Enter your name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                decoration: const InputDecoration(hintText: 'Email Address'),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                enabled: !_isSubmitting,
                obscureText: _obscurePassword,
                autofillHints: const <String>[AutofillHints.newPassword],
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    tooltip:
                        _obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').length < 6) {
                    return 'Use at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const Row(
                children: <Widget>[
                  Expanded(
                      child: Divider(thickness: 4, color: Color(0xFF3C4145))),
                  SizedBox(width: 4),
                  Expanded(
                      child: Divider(thickness: 4, color: Color(0xFF3C4145))),
                  SizedBox(width: 4),
                  Expanded(
                      child: Divider(thickness: 4, color: Color(0xFF3C4145))),
                  SizedBox(width: 4),
                  Expanded(
                      child: Divider(thickness: 4, color: Color(0xFF3C4145))),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !_isSubmitting,
                obscureText: _obscureConfirmPassword,
                autofillHints: const <String>[AutofillHints.newPassword],
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    tooltip: _obscureConfirmPassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (!_isSubmitting) {
                    _register();
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox.square(
                    dimension: 20,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                      side: const BorderSide(color: Color(0xFF6A637A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFFD9D5FF),
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFFD9D5FF),
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: authMutedTextColor,
                        fontSize: 15,
                        height: 1.25,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _isSubmitting ? null : _register,
                child: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 34),
              const AuthDivider(label: 'OR'),
              const SizedBox(height: 30),
              const GoogleAuthButton(),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: authMutedTextColor),
                  ),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => context.goNamed(AppRoute.login.name),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Log in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
