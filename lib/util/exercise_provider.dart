import 'package:flutter/foundation.dart';

class ExerciseProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _exercises = [];

  List<Map<String, dynamic>> get exercises => _exercises;

  void addExercise(Map<String, dynamic> exercise) {
    if (!_exercises.any((e) => e['name'] == exercise['name'])) {
      _exercises.add(exercise);
      notifyListeners();
    }
  }
}
