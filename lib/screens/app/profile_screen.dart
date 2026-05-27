import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../shared/providers/theme_provider.dart';
import '../auth/auth_api.dart';
import 'profile_image_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _logout(BuildContext context) {
    context.goNamed(AppRoute.login.name);
  }

  void _showImageOptions(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color bottomSheetBg = dark ? const Color(0xFF161A1D) : Colors.white;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bottomSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(profileImageProvider.notifier).pickImage();
                },
              ),
              if (ref.read(profileImageProvider) != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(profileImageProvider.notifier).deleteImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode currentMode = ref.watch(themeModeProvider);
    final String? profileImagePath = ref.watch(profileImageProvider);
    final bool isDark = currentMode == ThemeMode.dark;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive colours derived from theme
    final Color scaffoldBg = dark ? const Color(0xFF101415) : const Color(0xFFF0F2F5);
    final Color cardBg = dark ? const Color(0xFF161A1D) : Colors.white;
    final Color iconBg = dark ? const Color(0xFF1E2327) : const Color(0xFFEEEFF3);
    final Color titleColor = dark ? const Color(0xFFEAE6F5) : const Color(0xFF1A1A2E);
    final Color subtitleColor = dark ? const Color(0xFF7A7A8A) : const Color(0xFF8A8A9A);
    final Color sectionColor = dark ? const Color(0xFF6B7077) : const Color(0xFF9A9AAA);
    final Color iconColor = dark ? const Color(0xFFD3CEE2) : const Color(0xFF5B5B7A);
    final Color chevronColor = dark ? const Color(0xFF4A4F55) : const Color(0xFFBBBBC8);
    final Color dividerColor = dark ? const Color(0xFF1E2327) : const Color(0xFFEEEEF5);
    final Color logoutBg = dark ? const Color(0xFF161A1D) : Colors.white;
    final Color logoutBorder = dark ? const Color(0xFF2A2F32) : const Color(0xFFDDDDE8);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // ── Avatar + name + email + badges ──────────────────
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => _showImageOptions(context),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.4),
                          width: 2.5,
                        ),
                        image: DecorationImage(
                          image: profileImagePath != null 
                              ? FileImage(File(profileImagePath)) as ImageProvider
                              : const NetworkImage('https://i.pravatar.cc/200?img=47'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigoAccent.shade200,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ref.watch(userProvider).when(
                data: (user) => Column(
                  children: [
                    Text(
                      user['name'] ?? 'User',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Text(
                  'Error loading profile',
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),

              // ── Account Settings ────────────────────────────────
              _SectionHeader(label: 'ACCOUNT SETTINGS', color: sectionColor),
              _SettingsCard(
                bgColor: cardBg,
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Name, email, phone number',
                    iconBg: iconBg,
                    iconColor: iconColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    chevronColor: chevronColor,
                  ),
                  _AdaptiveDivider(color: dividerColor),
                  _SettingsTile(
                    icon: Icons.credit_card_outlined,
                    title: 'Billing & Subscription',
                    subtitle: 'Manage Pro Plan features',
                    iconBg: iconBg,
                    iconColor: iconColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    chevronColor: chevronColor,
                  ),
                ],
              ),

              // ── Security ────────────────────────────────────────
              _SectionHeader(label: 'SECURITY', color: sectionColor),
              _SettingsCard(
                bgColor: cardBg,
                children: [
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Password & Security',
                    subtitle: 'Update password, 2FA',
                    iconBg: iconBg,
                    iconColor: iconColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    chevronColor: chevronColor,
                  ),
                  _AdaptiveDivider(color: dividerColor),
                  _SettingsTile(
                    icon: Icons.devices_outlined,
                    title: 'Active Sessions',
                    subtitle: 'Manage logged in devices',
                    iconBg: iconBg,
                    iconColor: iconColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    chevronColor: chevronColor,
                  ),
                ],
              ),

              // ── App Preferences ─────────────────────────────────
              _SectionHeader(label: 'APP PREFERENCES', color: sectionColor),
              _SettingsCard(
                bgColor: cardBg,
                children: [
                  _ToggleTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Toggle app appearance',
                    value: isDark,
                    iconBg: iconBg,
                    iconColor: iconColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    onChanged: (v) {
                      ref.read(themeModeProvider.notifier).setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  _AdaptiveDivider(color: dividerColor),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Email and push alerts',
                    iconBg: iconBg,
                    iconColor: iconColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    chevronColor: chevronColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Logout ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Color(0xFFE84B4B), size: 20),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFE84B4B),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: logoutBorder),
                      backgroundColor: logoutBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.bgColor});
  final List<Widget> children;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.chevronColor,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color chevronColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: chevronColor, size: 20),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.iconBg,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconBg;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.indigoAccent.shade200,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF2A2F32),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _AdaptiveDivider extends StatelessWidget {
  const _AdaptiveDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(color: color, height: 1, indent: 70);
  }
}
