import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/catalog.dart';
import '../data/stats_service.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/choice_pill.dart';
import '../widgets/color_card.dart';
import '../widgets/detail_sheet.dart';
import '../widgets/goal_card.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_tile.dart';
import 'explore_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _pages = [HomeTab(), ExplorePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.paper,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        destinations: const [
          NavDestination(
            icon: Icons.today_outlined,
            activeIcon: Icons.today,
            label: 'Today',
          ),
          NavDestination(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view,
            label: 'Explore',
          ),
          NavDestination(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'You',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _moods = ['Happy', 'Calm', 'Sad', 'Angry'];

  String _mood = '';
  String _query = '';

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  List<SkillCategory> get _visible {
    if (_query.isEmpty) return skillCategories;
    return skillCategories
        .where((c) => c.name.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.paper,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<UserStats>(
          stream: StatsService.watch(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? UserStats.empty;
            final loading = !snapshot.hasData;
            final firstName =
                stats.name.isEmpty ? 'there' : stats.name.split(' ').first;
            final visible = _visible;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              children: [
                Text(_greeting.toUpperCase(), style: AppText.overline),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  child: loading
                      ? Container(
                          key: const ValueKey('placeholder'),
                          height: 42,
                          width: 170,
                          decoration: BoxDecoration(
                            color: Palette.lineSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                      : Text(
                          firstName,
                          key: ValueKey(firstName),
                          style: AppText.display,
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: AppText.meta,
                ),
                const SizedBox(height: 24),
                GoalCard(
                  done: stats.sessionsToday,
                  goal: stats.dailyGoal,
                  streak: stats.streak,
                  activeDays: stats.activeDays,
                  loading: loading,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        value: '${stats.completed}',
                        label: 'Completed',
                        icon: Icons.check_circle_outline,
                        color: Families.moss,
                        loading: loading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        value: '${stats.points}',
                        label: 'Points',
                        icon: Icons.auto_awesome_outlined,
                        color: Families.ochre,
                        loading: loading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SectionLabel('How you feel'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mood in _moods)
                      ChoicePill(
                        label: mood,
                        selected: _mood == mood,
                        onTap: () =>
                            setState(() => _mood = _mood == mood ? '' : mood),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                AppSearchField(
                  hint: 'Search categories',
                  onChanged: (v) =>
                      setState(() => _query = v.toLowerCase().trim()),
                ),
                const SizedBox(height: 24),
                SectionLabel('Categories', trailing: '${visible.length}'),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Text('Nothing matches that.', style: AppText.body),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 134,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final category = visible[i];
                      return ColorCard(
                        title: category.name,
                        meta: '${category.drills} drills',
                        icon: category.icon,
                        color: category.color,
                        onTap: () => showPlanSheet(context, category.plan),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
