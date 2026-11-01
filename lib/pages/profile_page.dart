import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/stats_service.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';
import '../widgets/app_snack.dart';
import '../widgets/avatar.dart';
import '../widgets/list_row.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_tile.dart';
import 'edit_profile.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _ensureUserDoc();
  }

  Future<void> _ensureUserDoc() async {
    final user = _user;
    if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'name': user.displayName ?? 'New User',
      'email': user.email,
      'photoUrl': user.photoURL,
      'photoData': null,
      'bio': '',
      'exercisesCompleted': 0,
      'points': 0,
      'streak': 0,
      'dailyGoal': 3,
      'sessionsToday': 0,
      'activeDays': <String>[],
    });
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

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Palette.paper,
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: Palette.paper,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<UserStats>(
          stream: StatsService.watch(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? UserStats.empty;
            final loading = !snapshot.hasData;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              children: [
                Row(
                  children: [
                    Avatar(
                      photoData: stats.photoData,
                      photoUrl: stats.photoUrl,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats.name.isEmpty ? 'Your profile' : stats.name,
                            style: AppText.h1.copyWith(fontSize: 23),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stats.email.isEmpty
                                ? (user.email ?? '')
                                : stats.email,
                            style: AppText.meta,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        value: '${stats.completed}',
                        label: 'Sessions',
                        icon: Icons.check_circle_outline,
                        color: Families.moss,
                        loading: loading,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        value: '${stats.points}',
                        label: 'Points',
                        icon: Icons.auto_awesome_outlined,
                        color: Families.ochre,
                        loading: loading,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        value: '${stats.streak}',
                        label: 'Streak',
                        icon: Icons.local_fire_department_outlined,
                        color: Families.ember,
                        loading: loading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                  decoration: BoxDecoration(
                    color: Families.indigo.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 18, color: Families.indigo.deep),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Daily goal',
                          style: AppText.h3.copyWith(color: Families.indigo.deep),
                        ),
                      ),
                      Text(
                        '${stats.sessionsToday} of ${stats.dailyGoal} today',
                        style: AppText.meta.copyWith(
                          color: Families.indigo.deep.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (stats.bio.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  const SectionLabel('About'),
                  Text(stats.bio,
                      style: AppText.body.copyWith(color: Palette.ink)),
                ],
                const SizedBox(height: 30),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Palette.line),
                      bottom: BorderSide(color: Palette.line),
                    ),
                  ),
                  child: RowGroup(
                    children: [
                      ListRow(
                        title: 'Edit profile',
                        onTap: () => _push(const EditProfilePage()),
                      ),
                      ListRow(
                        title: 'Settings',
                        onTap: () => _push(const SettingsPage()),
                      ),
                      ListRow(
                        title: 'Sign out',
                        titleColor: Palette.danger,
                        showChevron: false,
                        onTap: _signOut,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
