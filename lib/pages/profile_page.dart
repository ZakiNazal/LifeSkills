// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:exercise/pages/edit_profile.dart';
import 'package:exercise/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      if (_user == null) {
        setState(() { _error = 'Not authenticated'; _isLoading = false; });
        return;
      }
      final ref = FirebaseFirestore.instance.collection('users').doc(_user.uid);
      final snap = await ref.get();
      if (!mounted) return;

      if (snap.exists) {
        setState(() { _userData = snap.data()!; _isLoading = false; });
      } else {
        final defaults = {
          'name': _user.displayName ?? 'New User',
          'email': _user.email,
          'photoUrl': _user.photoURL,
          'bio': '',
          'exercisesCompleted': 0,
          'points': 0,
          'streak': 0,
        };
        await ref.set(defaults);
        if (!mounted) return;
        setState(() { _userData = defaults; _isLoading = false; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Error loading profile'; _isLoading = false; });
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
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xffF0F4F8), body: Center(child: CircularProgressIndicator(color: Color(0xff1565c0))));
    if (_error != null) return Scaffold(backgroundColor: const Color(0xffF0F4F8), body: Center(child: Text(_error!, style: const TextStyle(fontFamily: 'Rubik'))));

    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStats(),
                const SizedBox(height: 20),
                if ((_userData['bio'] as String?)?.isNotEmpty == true) ...[
                  _buildBio(),
                  const SizedBox(height: 20),
                ],
                _buildActions(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final photoUrl = _userData['photoUrl'] as String?;
    return Container(
      color: const Color(0xff1565c0),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 28,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person_rounded, size: 48, color: Colors.white) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    _fetchUserData();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, size: 14, color: Color(0xff1565c0)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _userData['name'] as String? ?? 'User',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['email'] as String? ?? '',
            style: TextStyle(fontSize: 14, fontFamily: 'Rubik', color: Colors.white.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(icon: Icons.check_circle_rounded, value: '${_userData['exercisesCompleted'] ?? 0}', label: 'Exercises', color: const Color(0xff10B981)),
          _Divider(),
          _StatItem(icon: Icons.star_rounded, value: '${_userData['points'] ?? 0}', label: 'Points', color: const Color(0xffF59E0B)),
          _Divider(),
          _StatItem(icon: Icons.local_fire_department_rounded, value: '${_userData['streak'] ?? 0}', label: 'Day Streak', color: const Color(0xffF97316)),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xff64748B))),
          const SizedBox(height: 6),
          Text(_userData['bio'] as String, style: const TextStyle(fontFamily: 'Rubik', fontSize: 15, color: Color(0xff1A1A2E), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        _ActionTile(
          icon: Icons.edit_rounded,
          label: 'Edit Profile',
          color: const Color(0xff1565c0),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
            _fetchUserData();
          },
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.settings_rounded,
          label: 'Settings',
          color: const Color(0xff475569),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.logout_rounded,
          label: 'Sign Out',
          color: Colors.red[600]!,
          onTap: _signOut,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Color(0xff1A1A2E))),
        Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Rubik', color: Color(0xff64748B))),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: const Color(0xffE2E8F0));
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w600, fontSize: 15, color: color)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
