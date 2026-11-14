import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/screens/workout/workout_screen.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Abas de categoria usam tokens semanticos do colorScheme no Modo Alto Contraste',
    (WidgetTester tester) async {
      final highContrastScheme = AppTheme.highContrastTheme.colorScheme;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciciosProvider.overrideWith((ref) => Stream.value(const [])),
          ],
          child: MaterialApp(
            theme: AppTheme.highContrastTheme,
            home: const WorkoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final heartTabFinder = find.ancestor(
        of: find.byIcon(Icons.favorite),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius ==
                  BorderRadius.circular(16),
        ),
      );
      final muscleTabFinder = find.ancestor(
        of: find.byIcon(Icons.fitness_center),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius ==
                  BorderRadius.circular(16),
        ),
      );

      final heartContainer = tester.widget<Container>(heartTabFinder);
      final muscleContainer = tester.widget<Container>(muscleTabFinder);

      final heartDecoration = heartContainer.decoration as BoxDecoration?;
      final muscleDecoration = muscleContainer.decoration as BoxDecoration?;

      expect(
        heartDecoration?.color,
        equals(highContrastScheme.surfaceContainerHighest),
      );
      expect(
        muscleDecoration?.color,
        equals(highContrastScheme.surfaceContainerLow),
      );
      expect(heartDecoration?.border, isNotNull);
      expect(muscleDecoration?.border, isNull);

      // Alterna para a aba Musculo e verifica atualizacao dos tokens
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      final updatedHeartDecoration =
          tester.widget<Container>(heartTabFinder).decoration
              as BoxDecoration?;
      final updatedMuscleDecoration =
          tester.widget<Container>(muscleTabFinder).decoration
              as BoxDecoration?;

      expect(
        updatedHeartDecoration?.color,
        equals(highContrastScheme.surfaceContainerLow),
      );
      expect(
        updatedMuscleDecoration?.color,
        equals(highContrastScheme.surfaceContainerHighest),
      );
      expect(updatedHeartDecoration?.border, isNull);
      expect(updatedMuscleDecoration?.border, isNotNull);
    },
  );

  testWidgets(
    'Exibe mensagem amigavel e registra erro via debugPrint sem expor excecao crua',
    (WidgetTester tester) async {
      final logs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          logs.add(message);
        }
      };

      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exerciciosProvider.overrideWith(
                (ref) => Stream.error(
                  Exception('FirebaseException: PERMISSION_DENIED'),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.highContrastTheme,
              home: const WorkoutScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Nenhuma excecao crua visivel na UI
        expect(find.textContaining('FirebaseException'), findsNothing);
        expect(find.textContaining('PERMISSION_DENIED'), findsNothing);
        expect(find.textContaining('Erro:'), findsNothing);

        // Mensagem amigavel visivel e acessivel
        final friendlyFinder = find.text(
          'Não foi possível carregar os exercícios no momento. Por favor, tente novamente mais tarde.',
        );
        expect(friendlyFinder, findsOneWidget);

        final friendlyText = tester.widget<Text>(friendlyFinder);
        expect(friendlyText.style?.fontSize, greaterThanOrEqualTo(18));

        // Erro tecnico registrado no debugPrint
        expect(
          logs.any((log) => log.contains('PERMISSION_DENIED')),
          isTrue,
        );
      } finally {
        debugPrint = originalDebugPrint;
      }
    },
  );
}

