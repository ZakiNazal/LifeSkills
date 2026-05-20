// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:exercise/pages/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setString('selected_language', _selectedLanguage);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = info.version);
  }

  Future<void> _sendPasswordReset() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to ${user.email}', style: const TextStyle(fontFamily: 'Rubik')),
          backgroundColor: const Color(0xff10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to send reset email', style: TextStyle(fontFamily: 'Rubik')),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'Rubik')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xff1565c0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Account'),
          _SettingsCard(children: [
            _Tile(icon: Icons.person_rounded, label: 'Edit Profile', iconColor: const Color(0xff1565c0), onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
            }),
            _divider(),
            _Tile(icon: Icons.lock_rounded, label: 'Change Password', iconColor: const Color(0xff7C3AED), onTap: _sendPasswordReset),
          ]),
          _SectionLabel('Preferences'),
          _SettingsCard(children: [
            SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (v) { setState(() => _notificationsEnabled = v); _saveSettings(); },
              activeThumbColor: const Color(0xff1565c0),
              secondary: _iconBox(Icons.notifications_rounded, const Color(0xffF97316)),
              title: const Text('Notifications', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w500, color: Color(0xff1A1A2E))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            _divider(),
            ListTile(
              leading: _iconBox(Icons.language_rounded, const Color(0xff0891B2)),
              title: const Text('Language', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w500, color: Color(0xff1A1A2E))),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  style: const TextStyle(color: Color(0xff1A1A2E), fontFamily: 'Rubik'),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  onChanged: (v) { if (v != null) { setState(() => _selectedLanguage = v); _saveSettings(); } },
                  items: ['English', 'Spanish', 'French', 'German']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ]),
          _SectionLabel('Support'),
          _SettingsCard(children: [
            _Tile(icon: Icons.help_rounded, label: 'Help Center', iconColor: const Color(0xff10B981), onTap: () {}),
            _divider(),
            _Tile(icon: Icons.privacy_tip_rounded, label: 'Privacy Policy', iconColor: const Color(0xff64748B), onTap: () {}),
            _divider(),
            _Tile(icon: Icons.description_rounded, label: 'Terms of Service', iconColor: const Color(0xff64748B), onTap: () {}),
          ]),
          _SectionLabel('About'),
          _SettingsCard(children: [
            ListTile(
              leading: _iconBox(Icons.info_rounded, const Color(0xff1565c0)),
              title: const Text('App Version', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w500, color: Color(0xff1A1A2E))),
              trailing: Text(_appVersion, style: const TextStyle(fontFamily: 'Rubik', color: Color(0xff64748B))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ]),
          const SizedBox(height: 8),
          _SettingsCard(children: [
            _Tile(icon: Icons.logout_rounded, label: 'Sign Out', iconColor: Colors.red[600]!, textColor: Colors.red[600]!, onTap: _signOut),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Divider _divider() => const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xffF1F5F9));
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _Tile({required this.icon, required this.label, required this.iconColor, required this.onTap, this.textColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label, style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w500, color: textColor ?? const Color(0xff1A1A2E))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xffCBD5E1)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(text.toUpperCase(), style: const TextStyle(fontFamily: 'Rubik', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff94A3B8), letterSpacing: 1.2)),
    );
  }
}
