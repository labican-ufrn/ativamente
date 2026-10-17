import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_academia/models/exercicio.dart';
import 'package:app_academia/providers/active_exercise_provider.dart';
import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/workout/workout_screen.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final testExercicio = Exercicio(
    id: 'ex-coracao-1',
    nome: 'Caminhada Leve',
    descricao: 'Caminhe no ritmo confortável por 10 minutos',
    midia: '',
    statusRealizado: false,
    categoria: Categoria(nome: 'Coracao', icone: 'favorite'),
    tipo: Tipo(nome: 'Aeróbico', icone: 'directions_walk'),
  );

  Widget createWorkoutScreenTestWidget({
    required ProviderContainer container,
    ThemeData? theme,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: theme ?? AppTheme.theme,
        home: const WorkoutScreen(),
      ),
    );
  }

  group('WorkoutScreen - Botão de execução do exercício (Issue #44)', () {
    testWidgets('Garante alvo de toque >= 48dp e alinhamento no card', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          exerciciosProvider.overrideWith(
            (ref) => Stream.value([testExercicio]),
          ),
          readScreenProvider.overrideWith((ref, text) => () {}),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createWorkoutScreenTestWidget(container: container),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.descendant(
        of: find.byType(Card),
        matching: find.byType(IconButton),
      );
      expect(buttonFinder, findsOneWidget);

      final buttonSize = tester.getSize(buttonFinder);
      expect(
        buttonSize.width,
        greaterThanOrEqualTo(48.0),
        reason: 'A largura do botão deve ser no mínimo 48dp para acessibilidade',
      );
      expect(
        buttonSize.height,
        greaterThanOrEqualTo(48.0),
        reason: 'A altura do botão deve ser no mínimo 48dp para acessibilidade',
      );

      final iconButton = tester.widget<IconButton>(buttonFinder);
      expect(iconButton.tooltip, equals('Iniciar exercício'));
      expect(
        iconButton.constraints,
        equals(const BoxConstraints(minWidth: 48, minHeight: 48)),
      );

      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);
      final cardRect = tester.getRect(cardFinder);
      final buttonRect = tester.getRect(buttonFinder);

      expect(cardRect.contains(buttonRect.center), isTrue);
      expect(
        (buttonRect.center.dy - cardRect.center.dy).abs(),
        lessThanOrEqualTo(10.0),
        reason: 'O botão deve permanecer alinhado verticalmente no card',
      );
    });

    testWidgets('Alterna estado de execução ao tocar no botão ampliado', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          exerciciosProvider.overrideWith(
            (ref) => Stream.value([testExercicio]),
          ),
          readScreenProvider.overrideWith((ref, text) => () {}),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createWorkoutScreenTestWidget(container: container),
      );
      await tester.pumpAndSettle();

      final playButtonFinder = find.descendant(
        of: find.byType(Card),
        matching: find.byType(IconButton),
      );
      expect(playButtonFinder, findsOneWidget);

      await tester.tap(playButtonFinder);
      await tester.pumpAndSettle();

      expect(container.read(activeExerciseProvider).exerciseId, equals('ex-coracao-1'));
      expect(container.read(activeExerciseProvider).isRunning, isTrue);

      final pauseButton = tester.widget<IconButton>(playButtonFinder);
      expect(pauseButton.tooltip, equals('Pausar exercício'));

      final pauseSize = tester.getSize(playButtonFinder);
      expect(pauseSize.width, greaterThanOrEqualTo(48.0));
      expect(pauseSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(playButtonFinder);
      await tester.pumpAndSettle();

      expect(container.read(activeExerciseProvider).isRunning, isFalse);
      final resumedPlayButton = tester.widget<IconButton>(playButtonFinder);
      expect(resumedPlayButton.tooltip, equals('Iniciar exercício'));
    });

    testWidgets('Mantém contraste e cores corretas no modo alto contraste', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          exerciciosProvider.overrideWith(
            (ref) => Stream.value([testExercicio]),
          ),
          readScreenProvider.overrideWith((ref, text) => () {}),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createWorkoutScreenTestWidget(
          container: container,
          theme: AppTheme.highContrastTheme,
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.descendant(
        of: find.byType(Card),
        matching: find.byType(IconButton),
      );
      expect(buttonFinder, findsOneWidget);

      final iconButton = tester.widget<IconButton>(buttonFinder);
      expect(iconButton.color, equals(const Color(0xFFFFE600)));
      expect(iconButton.tooltip, equals('Iniciar exercício'));

      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
