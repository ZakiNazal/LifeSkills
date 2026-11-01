import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';
import '../widgets/app_text_field.dart';
import '../widgets/choice_pill.dart';
import '../widgets/color_card.dart';
import '../widgets/detail_sheet.dart';
import '../widgets/section_label.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const _filters = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  String _query = '';
  String _filter = 'All';

  List<Activity> get _visible {
    return activities.where((a) {
      final matchesQuery = _query.isEmpty || a.name.toLowerCase().contains(_query);
      final matchesFilter = _filter == 'All' ||
          a.difficulty == _filter ||
          a.difficulty == 'All levels';
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      backgroundColor: Palette.paper,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverList.list(
                children: [
                  Text('Explore', style: AppText.h1),
                  const SizedBox(height: 8),
                  Text('Ten ways to move. Pick one and start it.',
                      style: AppText.body),
                  const SizedBox(height: 20),
                  AppSearchField(
                    hint: 'Search activities',
                    onChanged: (v) =>
                        setState(() => _query = v.toLowerCase().trim()),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ChoicePill(
                    label: _filters[i],
                    selected: _filter == _filters[i],
                    onTap: () => setState(() => _filter = _filters[i]),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
              sliver: SliverToBoxAdapter(
                child: SectionLabel('Activities', trailing: '${visible.length}'),
              ),
            ),
            if (visible.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                sliver: SliverToBoxAdapter(
                  child: Text('No activities match that.', style: AppText.body),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 134,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final activity = visible[i];
                      return ColorCard(
                        title: activity.name,
                        meta: '${activity.minutes} min  ·  ${activity.difficulty}',
                        icon: activity.icon,
                        color: activity.color,
                        onTap: () => showPlanSheet(context, activity.plan),
                      );
                    },
                    childCount: visible.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
