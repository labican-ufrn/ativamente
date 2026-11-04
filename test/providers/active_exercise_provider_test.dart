import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/active_exercise_provider.dart';

void main() {
  late DateTime agora;
  DateTime relogio() => agora;

  ProviderContainer novoContainer() {
    final container = ProviderContainer(
      overrides: [nowProvider.overrideWithValue(relogio)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => agora = DateTime(2026, 1, 1));

  testWidgets('estado inicial não tem exercício ativo', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();

    final state = container.read(activeExerciseProvider);
    expect(state.exerciseId, isNull);
    expect(state.elapsedSeconds, 0);
    expect(state.isRunning, isFalse);
  });

  testWidgets('conta o tempo pelo relógio', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    expect(container.read(activeExerciseProvider).isRunning, isTrue);

    agora = agora.add(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1)); // um tick atualiza a UI
    expect(container.read(activeExerciseProvider).elapsedSeconds, 3);

    notifier.stopExercise();
  });

  testWidgets('tick perdido (app em segundo plano) não subconta o tempo', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    // O relógio avança 10s, mas chega apenas 1 callback do Timer.
    agora = agora.add(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(activeExerciseProvider).elapsedSeconds, 10);

    notifier.stopExercise();
  });

  testWidgets('pause congela o cronômetro', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    agora = agora.add(const Duration(seconds: 2));
    notifier.pauseExercise();

    agora = agora.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(activeExerciseProvider).elapsedSeconds, 2);
    expect(container.read(activeExerciseProvider).isRunning, isFalse);
  });

  testWidgets('retomar soma o que já tinha decorrido', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    agora = agora.add(const Duration(seconds: 4));
    notifier.pauseExercise();

    agora = agora.add(const Duration(seconds: 30)); // pausa longa (não conta)
    notifier.startExercise('a');

    agora = agora.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(activeExerciseProvider).elapsedSeconds, 6); // 4 + 2

    notifier.stopExercise();
  });

  testWidgets('trocar de exercício zera o cronômetro', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    agora = agora.add(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));

    notifier.startExercise('b');
    expect(container.read(activeExerciseProvider).exerciseId, 'b');
    expect(container.read(activeExerciseProvider).elapsedSeconds, 0);

    agora = agora.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(activeExerciseProvider).elapsedSeconds, 2);

    notifier.stopExercise();
  });

  testWidgets('toggle pausa/retoma o mesmo e troca ao tocar em outro', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.toggleExercise('a');
    expect(container.read(activeExerciseProvider).isRunning, isTrue);

    notifier.toggleExercise('a');
    expect(container.read(activeExerciseProvider).isRunning, isFalse);

    notifier.toggleExercise('a');
    expect(container.read(activeExerciseProvider).isRunning, isTrue);

    notifier.toggleExercise('b');
    expect(container.read(activeExerciseProvider).exerciseId, 'b');

    notifier.stopExercise();
  });

  testWidgets('stop limpa o estado e interrompe a contagem', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    agora = agora.add(const Duration(seconds: 1));
    notifier.stopExercise();

    final state = container.read(activeExerciseProvider);
    expect(state.exerciseId, isNull);
    expect(state.elapsedSeconds, 0);
    expect(state.isRunning, isFalse);

    agora = agora.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(activeExerciseProvider).elapsedSeconds, 0);
  });
}
