import 'package:flutter/material.dart';

import '../data/session.dart';
import '../pages/session_page.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';
import 'app_button.dart';

Future<void> showPlanSheet(BuildContext context, SessionPlan plan) async {
  final start = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Palette.ink.withValues(alpha: 0.4),
    builder: (_) => _PlanSheet(plan: plan),
  );

  if (start != true || !context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => SessionPage(plan: plan)),
  );
}

class _PlanSheet extends StatelessWidget {
  final SessionPlan plan;

  const _PlanSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = plan.color;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: color.tint,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color.deep.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Icon(plan.icon, size: 30, color: color.deep),
                  const SizedBox(height: 16),
                  Text(
                    plan.meta.toUpperCase(),
                    style: AppText.overline.copyWith(color: color.deep),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.title,
                    style: AppText.display.copyWith(
                      fontSize: 34,
                      color: color.deep,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.blurb, style: AppText.body),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('THE SESSION', style: AppText.overline),
                        Text(
                          '${plan.lengthLabel}  ·  ${plan.points} pts',
                          style: AppText.overline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (var i = 0; i < plan.steps.length; i++)
                      _StepRow(
                        index: i + 1,
                        step: plan.steps[i],
                        color: color,
                        last: i == plan.steps.length - 1,
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: SafeArea(
                top: false,
                child: AppButton(
                  'Start session',
                  icon: Icons.play_arrow,
                  tint: color.solid,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final SessionStep step;
  final ColorFamily color;
  final bool last;

  const _StepRow({
    required this.index,
    required this.step,
    required this.color,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.tint,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: AppText.label.copyWith(fontSize: 12.5, color: color.deep),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: AppText.h3),
                const SizedBox(height: 3),
                Text(step.detail, style: AppText.meta),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatClock(step.seconds),
            style: AppText.meta.copyWith(color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }
}
