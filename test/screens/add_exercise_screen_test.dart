import 'package:app_academia/screens/workout/add_exercise_screen.dart';
import 'package:app_academia/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe campos obrigatórios e limita nome a 150 caracteres', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.theme,
          home: const AddExerciseScreen(),
        ),
      ),
    );

    expect(find.text('Nome do exercício *'), findsOneWidget);
    expect(find.text('Descrição / instruções *'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).maxLength,
      150,
    );
  });

  testWidgets('exibe intensidade entre 1 e 10', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AddExerciseScreen())),
    );

    expect(find.byType(Slider), findsOneWidget);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.min, 1);
    expect(slider.max, 10);
    expect(find.textContaining('Intensidade: 5 - Leve'), findsOneWidget);
  });
}
