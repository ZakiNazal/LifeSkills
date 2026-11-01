import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class GoalCard extends StatelessWidget {
  final int done;
  final int goal;
  final int streak;
  final List<String> activeDays;
  final bool loading;
  final ColorFamily color;

  const GoalCard({
    super.key,
    required this.done,
    required this.goal,
    required this.streak,
    required this.activeDays,
    this.loading = false,
    this.color = Families.ember,
  });

  double get _progress => goal <= 0 ? 0 : (done / goal).clamp(0.0, 1.0);

  bool get _hit => goal > 0 && done >= goal;

  @override
  Widget build(BuildContext context) {
    const onColor = Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: color.solid,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _hit ? 'GOAL MET' : 'TODAY',
                style: AppText.overline.copyWith(
                  color: onColor.withValues(alpha: 0.72),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: onColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 14, color: onColor),
                    const SizedBox(width: 5),
                    Text(
                      '$streak day${streak == 1 ? '' : 's'}',
                      style: AppText.label.copyWith(
                          fontSize: 12, color: onColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          loading
              ? Container(
                  height: 42,
                  width: 120,
                  decoration: BoxDecoration(
                    color: onColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$done',
                      style: AppText.display.copyWith(color: onColor),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'of $goal session${goal == 1 ? '' : 's'}',
                        style: AppText.body.copyWith(
                          color: onColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: onColor.withValues(alpha: 0.24),
                valueColor: const AlwaysStoppedAnimation(onColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _WeekDots(activeDays: activeDays, onColor: onColor, checkColor: color.solid),
        ],
      ),
    );
  }
}

class _WeekDots extends StatelessWidget {
  final List<String> activeDays;
  final Color onColor;
  final Color checkColor;

  const _WeekDots({
    required this.activeDays,
    required this.onColor,
    required this.checkColor,
  });

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          _dot(monday.add(Duration(days: i)), today, _letters[i]),
      ],
    );
  }

  Widget _dot(DateTime day, DateTime today, String letter) {
    final key = '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    final active = activeDays.contains(key);
    final isToday = day == today;
    final future = day.isAfter(today);

    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? onColor : onColor.withValues(alpha: 0.16),
            border: isToday && !active
                ? Border.all(color: onColor.withValues(alpha: 0.85), width: 1.5)
                : null,
          ),
          child: active
              ? Icon(Icons.check, size: 13, color: checkColor)
              : null,
        ),
        const SizedBox(height: 7),
        Text(
          letter,
          style: AppText.overline.copyWith(
            fontSize: 10,
            letterSpacing: 0.4,
            color: onColor.withValues(alpha: future ? 0.4 : 0.72),
          ),
        ),
      ],
    );
  }
}
