import 'package:flutter/material.dart';
import '../theme/palette.dart';

class SessionStep {
  final String title;
  final String detail;
  final int seconds;

  const SessionStep(this.title, this.detail, this.seconds);
}

class SessionPlan {
  final String title;
  final String meta;
  final String blurb;
  final IconData icon;
  final ColorFamily color;
  final List<SessionStep> steps;

  const SessionPlan({
    required this.title,
    required this.meta,
    required this.blurb,
    required this.icon,
    required this.color,
    required this.steps,
  });

  int get totalSeconds =>
      steps.fold(0, (sum, step) => sum + step.seconds);

  int get minutes => (totalSeconds / 60).round();

  int get points {
    final earned = minutes * 2;
    return earned < 5 ? 5 : earned;
  }

  String get lengthLabel {
    final m = minutes;
    return m < 1 ? 'under a minute' : '$m min';
  }
}

String formatClock(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Activities do not have hand written steps, so build a warm up, main set and
/// cool down out of the activity length. Short sessions stay as one block.
List<SessionStep> buildActivitySteps(String name, int minutes, String focus) {
  if (minutes < 15) {
    return [SessionStep(name, focus, minutes * 60)];
  }
  return [
    const SessionStep(
      'Warm up',
      'Easy pace. Loosen up and get the blood moving before the main set.',
      180,
    ),
    SessionStep('Main set', focus, (minutes - 5) * 60),
    const SessionStep(
      'Cool down',
      'Slow it right down. Let your heart rate come back before you stop.',
      120,
    ),
  ];
}
