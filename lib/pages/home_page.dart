// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise/pages/explore_page.dart';
import 'package:exercise/pages/profile_page.dart';
import 'package:exercise/util/exercise_tile.dart';
import 'package:exercise/util/emoticon_face.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePageContent(),
      const ExplorePage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xffF0F4F8),
        color: Colors.blue[700]!,
        buttonBackgroundColor: const Color(0xff1565c0),
        height: 65,
        index: _currentIndex,
        animationDuration: const Duration(milliseconds: 250),
        items: const [
          Icon(Icons.home_rounded, size: 26, color: Colors.white),
          Icon(Icons.explore_rounded, size: 26, color: Colors.white),
          Icon(Icons.person_rounded, size: 26, color: Colors.white),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String _userName = '';
  String _selectedMood = '';
  bool _showNotifications = false;
  int _streak = 0;
  int _exercisesCompleted = 0;

  static const List<Map<String, dynamic>> _exercises = [
    {'icon': Icons.speaker_notes_rounded, 'name': 'Speaking Skills', 'count': 15, 'color': Color(0xffF59E0B)},
    {'icon': Icons.book_rounded, 'name': 'Reading Skills', 'count': 8, 'color': Color(0xff10B981)},
    {'icon': Icons.edit_note_rounded, 'name': 'Writing Skills', 'count': 10, 'color': Color(0xffEC4899)},
    {'icon': Icons.people_rounded, 'name': 'Understanding', 'count': 5, 'color': Color(0xffF97316)},
    {'icon': Icons.hearing_rounded, 'name': 'Hearing Skills', 'count': 12, 'color': Color(0xff8B5CF6)},
    {'icon': Icons.gamepad_rounded, 'name': 'Gaming Skills', 'count': 9, 'color': Color(0xffEF4444)},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!mounted || !doc.exists) return;
      final data = doc.data()!;
      setState(() {
        _userName = data['name'] as String? ?? 'there';
        _streak = (data['streak'] as num?)?.toInt() ?? 0;
        _exercisesCompleted = (data['exercisesCompleted'] as num?)?.toInt() ?? 0;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _formattedDate => DateFormat('EEEE, d MMM').format(DateTime.now());

  List<Map<String, dynamic>> get _filteredExercises {
    if (_searchQuery.isEmpty) return _exercises;
    return _exercises
        .where((e) => (e['name'] as String).toLowerCase().contains(_searchQuery))
        .toList();
  }

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
          if (_showNotifications)
            GestureDetector(
              onTap: () => setState(() => _showNotifications = false),
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          if (_showNotifications)
            Positioned(
              top: 90,
              right: 16,
              child: _NotificationPanel(onClose: () => setState(() => _showNotifications = false)),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xff1565c0),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting + (_userName.isNotEmpty ? ', $_userName!' : '!'),
                    style: const TextStyle(
                      letterSpacing: 0.5,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formattedDate,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontFamily: 'Rubik', fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(icon: Icons.local_fire_department_rounded, value: '$_streak', label: 'day streak', color: const Color(0xffF97316)),
              const SizedBox(width: 10),
              _StatChip(icon: Icons.check_circle_rounded, value: '$_exercisesCompleted', label: 'completed', color: const Color(0xff10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildMoodSection(),
          const SizedBox(height: 20),
          _buildExercisesSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        cursorColor: Colors.blue[700],
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        style: const TextStyle(fontFamily: 'Rubik', fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Rubik'),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xff1565c0)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Color(0xff1A1A2E)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            EmoticonFace(emoticonFace: '😊', mood: 'Happy', isSelected: _selectedMood == 'Happy', onSelected: (m) => setState(() => _selectedMood = m)),
            EmoticonFace(emoticonFace: '😔', mood: 'Sad', isSelected: _selectedMood == 'Sad', onSelected: (m) => setState(() => _selectedMood = m)),
            EmoticonFace(emoticonFace: '😌', mood: 'Calm', isSelected: _selectedMood == 'Calm', onSelected: (m) => setState(() => _selectedMood = m)),
            EmoticonFace(emoticonFace: '😠', mood: 'Angry', isSelected: _selectedMood == 'Angry', onSelected: (m) => setState(() => _selectedMood = m)),
          ],
        ),
      ],
    );
  }

  Widget _buildExercisesSection() {
    final filtered = _filteredExercises;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exercise Categories',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: Color(0xff1A1A2E)),
            ),
            Text(
              '${filtered.length} available',
              style: const TextStyle(fontSize: 13, fontFamily: 'Rubik', color: Color(0xff64748B)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No exercises found', style: TextStyle(color: Colors.grey[500], fontFamily: 'Rubik')),
            ),
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ex = filtered[index];
              return ExerciseTile(
                icon: ex['icon'] as IconData,
                exerciseName: ex['name'] as String,
                numberOfExercises: ex['count'] as int,
                color: ex['color'] as Color,
              );
            },
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            '$value $label',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Rubik', fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;
  const _NotificationPanel({required this.onClose});

  @override
  State<_NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<_NotificationPanel> {
  final List<Map<String, String>> _notifications = [
    {'icon': 'exercise', 'title': 'New exercise available', 'body': 'Check out the new speaking exercise!', 'time': '2h ago'},
    {'icon': 'reminder', 'title': 'Daily reminder', 'body': "Don't forget to complete your daily task.", 'time': '5h ago'},
    {'icon': 'achievement', 'title': 'Achievement unlocked', 'body': "You've completed 10 exercises this week!", 'time': '1d ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xff1565c0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Rubik', fontSize: 16)),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ),
            if (_notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No notifications', style: TextStyle(color: Colors.grey, fontFamily: 'Rubik')),
              )
            else
              ..._notifications.asMap().entries.map((entry) {
                final i = entry.key;
                final n = entry.value;
                return Dismissible(
                  key: ValueKey('$i-${n['title']}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red[100],
                    child: Icon(Icons.delete_rounded, color: Colors.red[400]),
                  ),
                  onDismissed: (_) => setState(() => _notifications.removeAt(i)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xff1565c0).withValues(alpha: 0.1),
                      child: Icon(_iconForType(n['icon']!), color: const Color(0xff1565c0), size: 18),
                    ),
                    title: Text(n['title']!, style: const TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text(n['body']!, style: const TextStyle(fontFamily: 'Rubik', fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(n['time']!, style: TextStyle(fontFamily: 'Rubik', fontSize: 11, color: Colors.grey[500])),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'exercise' => Icons.fitness_center_rounded,
      'reminder' => Icons.alarm_rounded,
      'achievement' => Icons.emoji_events_rounded,
      _ => Icons.notifications_rounded,
    };
  }
}
