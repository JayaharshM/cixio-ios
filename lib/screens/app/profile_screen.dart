import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    context.goNamed(AppRoute.login.name);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF101415),
            Color(0xFF070A12),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD9D4FF),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      size: 48,
                      color: Color(0xFFD9D4FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'user@example.com',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF9B9BA8),
                        ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF2A2F32),
              height: 1,
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFFD3CEE2),
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(color: Color(0xFFE9E5F5)),
                    ),
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: Color(0xFFD3CEE2),
                    ),
                    title: const Text(
                      'Help & Support',
                      style: TextStyle(color: Color(0xFFE9E5F5)),
                    ),
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Color(0xFFD3CEE2),
                    ),
                    title: const Text(
                      'About',
                      style: TextStyle(color: Color(0xFFE9E5F5)),
                    ),
                    onTap: () {
                      // Navigate to about
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE84B4B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
