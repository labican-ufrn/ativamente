import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/active_exercise_provider.dart';

void main() {
  ProviderContainer novoContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  testWidgets('estado inicial não tem exercício ativo', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();

    final state = container.read(activeExerciseProvider);
    expect(state.exerciseId, isNull);
    expect(state.elapsedSeconds, 0);
    expect(state.isRunning, isFalse);
  });

  testWidgets('startExercise marca ativo e o cronômetro incrementa', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    expect(container.read(activeExerciseProvider).exerciseId, 'a');
    expect(container.read(activeExerciseProvider).isRunning, isTrue);

    await tester.pump(const Duration(seconds: 3));
    expect(container.read(activeExerciseProvider).elapsedSeconds, 3);

    notifier.stopExercise();
  });

  testWidgets('pause congela o cronômetro', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    await tester.pump(const Duration(seconds: 2));
    notifier.pauseExercise();
    await tester.pump(const Duration(seconds: 5));

    expect(container.read(activeExerciseProvider).elapsedSeconds, 2);
    expect(container.read(activeExerciseProvider).isRunning, isFalse);
  });

  testWidgets('trocar de exercício zera o cronômetro e mantém um só ativo', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final container = novoContainer();
    final notifier = container.read(activeExerciseProvider.notifier);

    notifier.startExercise('a');
    await tester.pump(const Duration(seconds: 4));
    notifier.startExercise('b');

    expect(container.read(activeExerciseProvider).exerciseId, 'b');
    expect(container.read(activeExerciseProvider).elapsedSeconds, 0);

    await tester.pump(const Duration(seconds: 2));
    expect(container.read(activeExerciseProvider).elapsedSeconds, 2);

    notifier.stopExercise();
  });

  testWidgets('toggle pausa/retoma o mesmo e troca ao tocar em outro', (tester) async {
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
    await tester.pump(const Duration(seconds: 1));
    notifier.stopExercise();

    final state = container.read(activeExerciseProvider);
    expect(state.exerciseId, isNull);
    expect(state.elapsedSeconds, 0);
    expect(state.isRunning, isFalse);

    await tester.pump(const Duration(seconds: 2));
    expect(container.read(activeExerciseProvider).elapsedSeconds, 0);
  });
}
