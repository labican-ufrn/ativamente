import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveExerciseState {
  final String? exerciseId;
  final int elapsedSeconds;
  final bool isRunning;

  ActiveExerciseState({
    this.exerciseId,
    this.elapsedSeconds = 0,
    this.isRunning = false,
  });

  ActiveExerciseState copyWith({
    String? exerciseId,
    int? elapsedSeconds,
    bool? isRunning,
  }) {
    return ActiveExerciseState(
      exerciseId: exerciseId ?? this.exerciseId,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class ActiveExerciseNotifier extends Notifier<ActiveExerciseState> {
  Timer? _timer;

  @override
  ActiveExerciseState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return ActiveExerciseState();
  }

  void startExercise(String id) {
    if (state.exerciseId != id) {
      _timer?.cancel();
      state = ActiveExerciseState(
        exerciseId: id,
        isRunning: true,
        elapsedSeconds: 0,
      );
      _startTimer();
    } else if (!state.isRunning) {
      state = state.copyWith(isRunning: true);
      _startTimer();
    }
  }

  void pauseExercise() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void stopExercise() {
    _timer?.cancel();
    state = ActiveExerciseState();
  }

  void toggleExercise(String id) {
    if (state.exerciseId == id) {
      if (state.isRunning) {
        pauseExercise();
      } else {
        startExercise(id);
      }
    } else {
      startExercise(id);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }
}

final activeExerciseProvider =
    NotifierProvider<ActiveExerciseNotifier, ActiveExerciseState>(() {
      return ActiveExerciseNotifier();
    });
