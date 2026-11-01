import 'package:flutter/material.dart';

import '../theme/palette.dart';
import 'session.dart';

class SkillCategory {
  final String name;
  final IconData icon;
  final String blurb;
  final ColorFamily color;
  final List<SessionStep> steps;

  const SkillCategory({
    required this.name,
    required this.icon,
    required this.blurb,
    required this.color,
    required this.steps,
  });

  int get drills => steps.length;

  SessionPlan get plan => SessionPlan(
        title: name,
        meta: '$drills drills',
        blurb: blurb,
        icon: icon,
        color: color,
        steps: steps,
      );
}

class Activity {
  final String name;
  final IconData icon;
  final String description;
  final String focus;
  final String difficulty;
  final int minutes;
  final ColorFamily color;

  const Activity({
    required this.name,
    required this.icon,
    required this.description,
    required this.focus,
    required this.difficulty,
    required this.minutes,
    required this.color,
  });

  SessionPlan get plan => SessionPlan(
        title: name,
        meta: '$minutes min  ·  $difficulty',
        blurb: description,
        icon: icon,
        color: color,
        steps: buildActivitySteps(name, minutes, focus),
      );
}

const skillCategories = <SkillCategory>[
  SkillCategory(
    name: 'Speaking',
    icon: Icons.record_voice_over_outlined,
    color: Families.ember,
    blurb: 'Clarity, pace and confidence. Short drills you do out loud.',
    steps: [
      SessionStep(
        'Warm up',
        'Read any paragraph out loud. Finish every word, do not trail off.',
        60,
      ),
      SessionStep(
        'Pace control',
        'Read the same paragraph at half speed. Notice where you rush.',
        90,
      ),
      SessionStep(
        'No fillers',
        'Describe your day out loud. Every um or like, restart the sentence.',
        120,
      ),
    ],
  ),
  SkillCategory(
    name: 'Reading',
    icon: Icons.menu_book_outlined,
    color: Families.indigo,
    blurb: 'Comprehension and speed on passages you can finish in one sitting.',
    steps: [
      SessionStep(
        'Skim',
        'Pick a page. Read only the first line of each paragraph.',
        60,
      ),
      SessionStep(
        'Close read',
        'Read the page properly. Mark the one sentence carrying the argument.',
        180,
      ),
      SessionStep(
        'Recall',
        'Close the page. Say out loud what it actually claimed.',
        60,
      ),
    ],
  ),
  SkillCategory(
    name: 'Writing',
    icon: Icons.edit_outlined,
    color: Families.plum,
    blurb: 'Structure, tone and the instinct to cut. Bring something to write on.',
    steps: [
      SessionStep(
        'Brain dump',
        'Write without stopping. No editing, no backspace, no rereading.',
        180,
      ),
      SessionStep(
        'Cut a third',
        'Delete a third of what you wrote and keep the meaning intact.',
        120,
      ),
      SessionStep(
        'One sentence',
        'Compress the whole thing into a single sentence.',
        90,
      ),
    ],
  ),
  SkillCategory(
    name: 'Understanding',
    icon: Icons.groups_outlined,
    color: Families.moss,
    blurb: 'Reading people, holding attention, asking the better question.',
    steps: [
      SessionStep(
        'Listen back',
        'Recall your last conversation. What did the other person actually want?',
        90,
      ),
      SessionStep(
        'Better questions',
        'Write three questions you could have asked instead of talking.',
        120,
      ),
      SessionStep(
        'Read the room',
        'Describe the mood of a room you were in today, and your evidence.',
        90,
      ),
    ],
  ),
  SkillCategory(
    name: 'Listening',
    icon: Icons.hearing_outlined,
    color: Families.teal,
    blurb: 'Active listening with audio you respond to, not just hear.',
    steps: [
      SessionStep(
        'Single source',
        'Play something spoken. Follow one voice only and ignore the rest.',
        120,
      ),
      SessionStep(
        'Repeat back',
        'Pause it. Say what you heard in your own words, out loud.',
        90,
      ),
      SessionStep(
        'Detail catch',
        'Play the same clip again. Count what you missed the first time.',
        120,
      ),
    ],
  ),
  SkillCategory(
    name: 'Reaction',
    icon: Icons.bolt_outlined,
    color: Families.ochre,
    blurb: 'Timing and focus under light pressure. Quick, no equipment.',
    steps: [
      SessionStep(
        'Reset',
        'Sit still, breathe slow, bring your attention to a single point.',
        60,
      ),
      SessionStep(
        'Scan',
        'Track a moving object with your eyes only. Do not move your head.',
        90,
      ),
      SessionStep(
        'Sharp',
        'Tap along to a beat you pick. Lose it, start again.',
        90,
      ),
    ],
  ),
];

const activities = <Activity>[
  Activity(
    name: 'Yoga',
    icon: Icons.self_improvement_outlined,
    color: Families.plum,
    minutes: 25,
    difficulty: 'All levels',
    description:
        'Flexibility, balance and mental clarity through guided poses and breathing work that suits any level.',
    focus: 'Hold each pose longer than feels comfortable. Breathe through it.',
  ),
  Activity(
    name: 'Meditation',
    icon: Icons.spa_outlined,
    color: Families.indigo,
    minutes: 10,
    difficulty: 'Beginner',
    description:
        'Reduce stress and build focus. Works whether this is your first sit or your thousandth.',
    focus: 'Follow the breath. When you drift, come back without judging it.',
  ),
  Activity(
    name: 'Running',
    icon: Icons.directions_run_outlined,
    color: Families.moss,
    minutes: 30,
    difficulty: 'Intermediate',
    description:
        'Build cardiovascular endurance, from easy jogs to interval work and long distance.',
    focus: 'Steady effort you could just about hold a conversation through.',
  ),
  Activity(
    name: 'Cycling',
    icon: Icons.directions_bike_outlined,
    color: Families.ochre,
    minutes: 40,
    difficulty: 'All levels',
    description:
        'Low impact cardio that strengthens legs and core. Indoor spin or an outdoor route.',
    focus: 'Keep cadence high and resistance moderate. Spin, do not grind.',
  ),
  Activity(
    name: 'Swimming',
    icon: Icons.pool_outlined,
    color: Families.teal,
    minutes: 35,
    difficulty: 'Intermediate',
    description:
        'A full body workout that builds strength and endurance while staying easy on the joints.',
    focus: 'Long strokes, controlled breathing, count your laps in sets.',
  ),
  Activity(
    name: 'Weightlifting',
    icon: Icons.fitness_center_outlined,
    color: Families.ember,
    minutes: 50,
    difficulty: 'Advanced',
    description:
        'Build muscle and raise your metabolic floor with progressive strength work.',
    focus: 'Compound lifts first. Leave one or two reps in reserve each set.',
  ),
  Activity(
    name: 'Dancing',
    icon: Icons.music_note_outlined,
    color: Families.berry,
    minutes: 35,
    difficulty: 'Beginner',
    description:
        'Get your heart rate up without noticing. Anything from Zumba to hip hop cardio.',
    focus: 'Pick tracks you actually like and keep moving between them.',
  ),
  Activity(
    name: 'Hiking',
    icon: Icons.terrain_outlined,
    color: Families.moss,
    minutes: 60,
    difficulty: 'Intermediate',
    description:
        'Build endurance and leg strength on real terrain, from flat walks to steep ascents.',
    focus: 'Short steps on the climbs. Save something for the way back.',
  ),
  Activity(
    name: 'Golf',
    icon: Icons.sports_golf_outlined,
    color: Families.teal,
    minutes: 60,
    difficulty: 'All levels',
    description:
        'Swing mechanics, the short game and course strategy, from first round to club level.',
    focus: 'Half the time on putting and chipping. That is where shots go.',
  ),
  Activity(
    name: 'Skiing',
    icon: Icons.downhill_skiing_outlined,
    color: Families.berry,
    minutes: 60,
    difficulty: 'Advanced',
    description:
        'Slope technique, moguls and off piste, plus off season conditioning.',
    focus: 'Weight forward, pressure the downhill ski, look where you are going.',
  ),
];
