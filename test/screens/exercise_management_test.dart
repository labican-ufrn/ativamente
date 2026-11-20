import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_academia/models/exercicio.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/admin/exercise_form.dart';

void main() {
  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [readScreenProvider.overrideWith((ref, text) => () {})],
    );
  }

  testWidgets('valida campos obrigatórios antes de salvar', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);
    var saveCalls = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ExerciseForm(
            title: 'Cadastrar Exercício',
            onSave: (exercise) async {
              saveCalls++;
            },
          ),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Salvar exercício'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar exercício'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o nome.'), findsOneWidget);
    expect(saveCalls, 0);
  });

  testWidgets('persiste os campos preenchidos no envio válido', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);
    Exercicio? savedExercise;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ExerciseForm(
            title: 'Cadastrar Exercício',
            onSave: (exercise) async {
              savedExercise = exercise;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Caminhada leve');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Caminhar por dez minutos.',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Cardio');
    await tester.enterText(find.byType(TextFormField).at(3), 'Aeróbico');
    await tester.scrollUntilVisible(
      find.text('Salvar exercício'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar exercício'));
    await tester.pumpAndSettle();

    expect(savedExercise, isNotNull);
    expect(savedExercise!.nome, 'Caminhada leve');
    expect(savedExercise!.descricao, 'Caminhar por dez minutos.');
    expect(savedExercise!.categoria.nome, 'Cardio');
    expect(savedExercise!.tipo.nome, 'Aeróbico');
    expect(savedExercise!.intensidade, 1);
  });
}
