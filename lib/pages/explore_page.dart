// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'color': Color(0xff7C3AED),
      'desc': 'Improve flexibility, balance, and mental clarity through guided yoga poses and breathing exercises suited for all levels.',
      'duration': '20–45 min',
      'difficulty': 'All levels',
    },
    {
      'name': 'Meditation',
      'icon': Icons.spa,
      'color': Color(0xff2563EB),
      'desc': 'Reduce stress and build focus with guided mindfulness sessions. Perfect for beginners and experienced practitioners alike.',
      'duration': '5–30 min',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Running',
      'icon': Icons.directions_run,
      'color': Color(0xff059669),
      'desc': 'Build cardiovascular endurance with structured run programs from easy jogs to interval sprints and long-distance training.',
      'duration': '20–60 min',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Cycling',
      'icon': Icons.directions_bike,
      'color': Color(0xffD97706),
      'desc': 'Low-impact cardio that strengthens your legs and core. Includes indoor spin sessions and outdoor route challenges.',
      'duration': '30–90 min',
      'difficulty': 'All levels',
    },
    {
      'name': 'Swimming',
      'icon': Icons.pool,
      'color': Color(0xff0891B2),
      'desc': 'A full-body workout that builds strength and endurance while being easy on joints. Great for recovery days too.',
      'duration': '30–60 min',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Weightlifting',
      'icon': Icons.fitness_center,
      'color': Color(0xffDC2626),
      'desc': 'Build muscle and boost metabolism with progressive strength training programs designed for safe, steady gains.',
      'duration': '45–75 min',
      'difficulty': 'Advanced',
    },
    {
      'name': 'Dancing',
      'icon': Icons.music_note,
      'color': Color(0xffDB2777),
      'desc': 'Get your heart pumping while having fun. Covers a range of styles from Zumba to hip-hop cardio.',
      'duration': '30–60 min',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Hiking',
      'icon': Icons.landscape,
      'color': Color(0xff92400E),
      'desc': 'Explore nature while building endurance and leg strength. Trail guides range from easy walks to challenging ascents.',
      'duration': '60–180 min',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Golf',
      'icon': Icons.golf_course,
      'color': Color(0xff166534),
      'desc': 'Improve your swing mechanics, short game, and course strategy with drills from beginner to competitive level.',
      'duration': '60–120 min',
      'difficulty': 'All levels',
    },
    {
      'name': 'Skiing',
      'icon': Icons.downhill_skiing_rounded,
      'color': Color(0xff0284C7),
      'desc': 'Master slope technique, moguls, and off-piste skiing with video-guided drills and fitness conditioning plans.',
      'duration': '60–240 min',
      'difficulty': 'Advanced',
    },
  ];

  String _searchQuery = '';

  List<Map<String, dynamic>> get _filtered => _categories
      .where((c) => (c['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                      color: Color(0xff1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${filtered.length} activities available',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Rubik', color: Color(0xff64748B)),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: TextField(
                      cursorColor: Colors.blue[700],
                      style: const TextStyle(fontFamily: 'Rubik', fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search activities...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Rubik'),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xff1565c0)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 300),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: _CategoryCard(category: filtered[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = category['color'] as Color;
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Center(child: Icon(category['icon'] as IconData, size: 44, color: color)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'] as String,
                    style: const TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1A1A2E)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(category['duration'] as String, style: TextStyle(fontFamily: 'Rubik', fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      category['difficulty'] as String,
                      style: TextStyle(fontFamily: 'Rubik', fontSize: 10, fontWeight: FontWeight.w600, color: color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final color = category['color'] as Color;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Container(
                height: 100,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
                child: Center(child: Icon(category['icon'] as IconData, size: 52, color: color)),
              ),
              const SizedBox(height: 18),
              Text(
                category['name'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Rubik', color: color),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(icon: Icons.schedule_rounded, label: category['duration'] as String, color: color),
                  const SizedBox(width: 10),
                  _InfoChip(icon: Icons.bar_chart_rounded, label: category['difficulty'] as String, color: color),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                category['desc'] as String,
                style: const TextStyle(fontSize: 15, fontFamily: 'Rubik', color: Color(0xff475569), height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Start Activity', style: TextStyle(fontSize: 16, fontFamily: 'Rubik', fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontFamily: 'Rubik', fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
