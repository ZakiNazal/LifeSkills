import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/stats_service.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';
import '../widgets/app_snack.dart';
import '../widgets/list_row.dart';
import '../widgets/section_label.dart';
import 'edit_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _languages = ['English', 'Spanish', 'French', 'German'];

  bool _notifications = true;
  String _language = 'English';
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool('notifications_enabled') ?? true;
      _language = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notifications);
    await prefs.setString('selected_language', _language);
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = info.version);
  }

  Future<void> _pickLanguage() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Palette.ink.withValues(alpha: 0.35),
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel('Language'),
                RowGroup(
                  children: [
                    for (final language in _languages)
                      ListRow(
                        title: language,
                        showChevron: false,
                        trailingText: language == _language ? 'Selected' : null,
                        onTap: () => Navigator.pop(sheetContext, language),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (picked == null || picked == _language) return;
    setState(() => _language = picked);
    await _saveSettings();
  }

  Future<void> _pickDailyGoal(int current) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Palette.ink.withValues(alpha: 0.35),
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel('Sessions per day'),
                RowGroup(
                  children: [
                    for (var n = 1; n <= 6; n++)
                      ListRow(
                        title: n == 1 ? '1 session' : '$n sessions',
                        showChevron: false,
                        trailingText: n == current ? 'Current' : null,
                        onTap: () => Navigator.pop(sheetContext, n),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (picked == null || picked == current) return;
    await StatsService.setDailyGoal(picked);
    if (!mounted) return;
    showSnack(context, 'Daily goal set to $picked');
  }

  Future<void> _sendPasswordReset() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      showSnack(context, 'Reset link sent to $email');
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'Could not send the reset email', isError: true);
    }
  }

  Future<void> _signOut() async {
    final ok = await confirm(
      context,
      title: 'Sign out',
      message: 'You will need your email and password to get back in.',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (!ok) return;
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.paper,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 21),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        children: [
          const SectionLabel('Account'),
          _Group(
            children: [
              ListRow(
                title: 'Edit profile',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              ),
              ListRow(
                title: 'Change password',
                subtitle: 'We email you a reset link',
                onTap: _sendPasswordReset,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const SectionLabel('Preferences'),
          StreamBuilder<UserStats>(
            stream: StatsService.watch(),
            builder: (context, snapshot) {
              final goal = snapshot.data?.dailyGoal ?? 3;
              return _Group(
                children: [
                  ListRow(
                    title: 'Daily goal',
                    subtitle: 'How many sessions count as a full day',
                    trailingText: goal == 1 ? '1 session' : '$goal sessions',
                    onTap: () => _pickDailyGoal(goal),
                  ),
                  _SwitchRow(
                    title: 'Notifications',
                    subtitle: 'Daily reminders and streak alerts',
                    value: _notifications,
                    onChanged: (v) {
                      setState(() => _notifications = v);
                      _saveSettings();
                    },
                  ),
                  ListRow(
                    title: 'Language',
                    trailingText: _language,
                    onTap: _pickLanguage,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const SectionLabel('Support'),
          _Group(
            children: [
              ListRow(title: 'Help centre', onTap: () {}),
              ListRow(title: 'Privacy policy', onTap: () {}),
              ListRow(title: 'Terms of service', onTap: () {}),
            ],
          ),
          const SizedBox(height: 32),
          _Group(
            children: [
              ListRow(
                title: 'Sign out',
                titleColor: Palette.danger,
                showChevron: false,
                onTap: _signOut,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              _version.isEmpty ? 'LifeSkills' : 'LifeSkills  ·  v$_version',
              style: AppText.meta.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Palette.line),
          bottom: BorderSide(color: Palette.line),
        ),
      ),
      child: RowGroup(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h3),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.meta),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Palette.ink,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Palette.line,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
