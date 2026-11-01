import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

class UserStats {
  final String name;
  final String email;
  final String bio;
  final String? photoUrl;
  final String? photoData;
  final int streak;
  final int completed;
  final int points;
  final int dailyGoal;
  final int sessionsToday;
  final List<String> activeDays;

  const UserStats({
    required this.name,
    required this.email,
    required this.bio,
    required this.photoUrl,
    required this.photoData,
    required this.streak,
    required this.completed,
    required this.points,
    required this.dailyGoal,
    required this.sessionsToday,
    required this.activeDays,
  });

  factory UserStats.fromMap(Map<String, dynamic> data) {
    final today = dayKey(DateTime.now());
    final lastActive = data['lastActiveDate'] as String?;
    final rawToday = (data['sessionsToday'] as num?)?.toInt() ?? 0;
    final days =
        (data['activeDays'] as List?)?.whereType<String>().toList() ?? const [];

    // The counter is only meaningful if it was last written today, otherwise a
    // new day has started and nothing has been done in it yet.
    final isStale = lastActive != today;

    return UserStats(
      name: (data['name'] as String?)?.trim() ?? '',
      email: data['email'] as String? ?? '',
      bio: (data['bio'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      photoData: data['photoData'] as String?,
      streak: _streakAsOfToday(
        (data['streak'] as num?)?.toInt() ?? 0,
        lastActive,
        today,
      ),
      completed: (data['exercisesCompleted'] as num?)?.toInt() ?? 0,
      points: (data['points'] as num?)?.toInt() ?? 0,
      dailyGoal: (data['dailyGoal'] as num?)?.toInt() ?? 3,
      sessionsToday: isStale ? 0 : rawToday,
      activeDays: days,
    );
  }

  /// A streak survives one quiet day (today, until it ends). Anything older and
  /// it has already lapsed, so show zero rather than a number that is not true.
  static int _streakAsOfToday(int stored, String? lastActive, String today) {
    if (stored <= 0 || lastActive == null) return 0;
    if (lastActive == today) return stored;
    final yesterday =
        dayKey(DateTime.now().subtract(const Duration(days: 1)));
    return lastActive == yesterday ? stored : 0;
  }

  double get goalProgress =>
      dailyGoal <= 0 ? 0 : (sessionsToday / dailyGoal).clamp(0.0, 1.0);

  static const empty = UserStats(
    name: '',
    email: '',
    bio: '',
    photoUrl: null,
    photoData: null,
    streak: 0,
    completed: 0,
    points: 0,
    dailyGoal: 3,
    sessionsToday: 0,
    activeDays: [],
  );
}

class SessionResult {
  final int pointsEarned;
  final int streak;
  final int sessionsToday;
  final int dailyGoal;

  const SessionResult({
    required this.pointsEarned,
    required this.streak,
    required this.sessionsToday,
    required this.dailyGoal,
  });

  bool get goalMet => sessionsToday >= dailyGoal;
}

class StatsService {
  static DocumentReference<Map<String, dynamic>>? _ref() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static Stream<UserStats> watch() async* {
    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      if (user == null) {
        yield UserStats.empty;
      } else {
        yield* FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .map((snap) =>
                UserStats.fromMap(snap.data() ?? const <String, dynamic>{}));
      }
    }
  }

  static Future<void> setDailyGoal(int goal) async {
    final ref = _ref();
    if (ref == null) return;
    await ref.set({'dailyGoal': goal}, SetOptions(merge: true));
  }

  /// Runs in a transaction so two sessions finishing close together cannot both
  /// read the same streak and write it back twice.
  static Future<SessionResult> completeSession({required int points}) async {
    final ref = _ref();
    if (ref == null) {
      return SessionResult(
        pointsEarned: points,
        streak: 0,
        sessionsToday: 0,
        dailyGoal: 3,
      );
    }

    return FirebaseFirestore.instance.runTransaction<SessionResult>((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};

      final now = DateTime.now();
      final today = dayKey(now);
      final yesterday = dayKey(now.subtract(const Duration(days: 1)));
      final lastActive = data['lastActiveDate'] as String?;

      var streak = (data['streak'] as num?)?.toInt() ?? 0;
      if (lastActive == today) {
        if (streak < 1) streak = 1;
      } else if (lastActive == yesterday) {
        streak += 1;
      } else {
        streak = 1;
      }

      final sessionsToday =
          lastActive == today ? ((data['sessionsToday'] as num?)?.toInt() ?? 0) + 1 : 1;

      final days =
          (data['activeDays'] as List?)?.whereType<String>().toSet() ?? <String>{};
      days.add(today);
      final trimmed = days.toList()..sort();
      final recent = trimmed.length > 21
          ? trimmed.sublist(trimmed.length - 21)
          : trimmed;

      final dailyGoal = (data['dailyGoal'] as num?)?.toInt() ?? 3;

      tx.set(
        ref,
        {
          'streak': streak,
          'lastActiveDate': today,
          'sessionsToday': sessionsToday,
          'activeDays': recent,
          'dailyGoal': dailyGoal,
          'exercisesCompleted':
              ((data['exercisesCompleted'] as num?)?.toInt() ?? 0) + 1,
          'points': ((data['points'] as num?)?.toInt() ?? 0) + points,
        },
        SetOptions(merge: true),
      );

      return SessionResult(
        pointsEarned: points,
        streak: streak,
        sessionsToday: sessionsToday,
        dailyGoal: dailyGoal,
      );
    });
  }
}
