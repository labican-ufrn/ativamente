import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fonte de tempo do cronômetro. Sobrescreva em teste para controlar o relógio.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

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

  /// Início do segmento em execução (null quando pausado/parado).
  DateTime? _inicio;

  /// Tempo já executado nos segmentos anteriores (pausas).
  Duration _acumulado = Duration.zero;

  DateTime get _agora => ref.read(nowProvider)();

  /// Tempo decorrido calculado por relógio (não por contagem de ticks): assim
  /// um tick atrasado — app em segundo plano, event loop ocupado — não subconta.
  int get _elapsed {
    final agora = _agora;
    final corrente = _inicio == null
        ? Duration.zero
        : agora.difference(_inicio!);
    final total = _acumulado + corrente;
    return total.isNegative ? 0 : total.inSeconds;
  }

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
      _acumulado = Duration.zero;
      _inicio = _agora;
      state = ActiveExerciseState(
        exerciseId: id,
        isRunning: true,
        elapsedSeconds: 0,
      );
      _startTimer();
    } else if (!state.isRunning) {
      _inicio = _agora;
      state = state.copyWith(isRunning: true, elapsedSeconds: _elapsed);
      _startTimer();
    }
  }

  void pauseExercise() {
    _timer?.cancel();
    if (_inicio != null) {
      _acumulado += _agora.difference(_inicio!);
      _inicio = null;
    }
    state = state.copyWith(isRunning: false, elapsedSeconds: _elapsed);
  }

  void stopExercise() {
    _timer?.cancel();
    _inicio = null;
    _acumulado = Duration.zero;
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
    // O tick só atualiza a UI; o valor vem do relógio (_elapsed).
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: _elapsed);
    });
  }
}

final activeExerciseProvider =
    NotifierProvider<ActiveExerciseNotifier, ActiveExerciseState>(
      ActiveExerciseNotifier.new,
    );
