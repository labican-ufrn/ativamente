import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_academia/models/exercicio.dart';
import 'package:app_academia/providers/active_exercise_provider.dart';
import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/workout/exercise_detail_screen.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late DateTime agora;
  DateTime relogio() => agora;

  final testExercicio = Exercicio(
    id: 'ex-1',
    nome: 'Caminhada Leve',
    descricao: 'Caminhe em ritmo confortável por 10 minutos.',
    midia: '',
    statusRealizado: false,
    intensidade: 3,
    categoria: Categoria(nome: 'Coracao', icone: 'favorite'),
    tipo: Tipo(nome: 'Aeróbico', icone: 'directions_walk'),
  );

  final outroExercicio = Exercicio(
    id: 'ex-2',
    nome: 'Agachamento na Cadeira',
    descricao: 'Sente e levante da cadeira com apoio.',
    midia: '',
    statusRealizado: false,
    intensidade: 6,
    categoria: Categoria(nome: 'Musculo', icone: 'fitness_center'),
    tipo: Tipo(nome: 'Força', icone: 'fitness_center'),
  );

  ProviderContainer criarContainer() {
    final container = ProviderContainer(
      overrides: [
        nowProvider.overrideWithValue(relogio),
        exerciciosProvider.overrideWith(
          (ref) => Stream.value([testExercicio, outroExercicio]),
        ),
        readScreenProvider.overrideWith((ref, text) => () {}),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    agora = DateTime(2026, 10, 30, 10, 0, 0);
  });

  group('ExerciseDetailScreen - Controle de Execução (US11 / Issue #52)', () {
    testWidgets(
      'Permite iniciar, pausar, retomar e parar o exercício com cronômetro em tempo real',
      (WidgetTester tester) async {
        final container = criarContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.theme,
              home: const ExerciseDetailScreen(exerciseId: 'ex-1'),
            ),
          ),
        );
        await tester.pump();

        // Estado inicial: Parado e 00:00
        expect(find.text('Parado'), findsOneWidget);
        expect(find.text('00:00'), findsOneWidget);
        expect(find.text('Iniciar'), findsOneWidget);
        expect(find.text('Pausar'), findsOneWidget);
        expect(find.text('Parar'), findsOneWidget);

        // Toca em Iniciar
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        expect(find.text('Em execução'), findsOneWidget);
        expect(container.read(activeExerciseProvider).exerciseId, 'ex-1');
        expect(container.read(activeExerciseProvider).isRunning, isTrue);

        // Avança 65 segundos no relógio e verifica atualização em tempo real
        agora = agora.add(const Duration(seconds: 65));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('01:05'), findsOneWidget);
        expect(container.read(activeExerciseProvider).elapsedSeconds, 65);

        // Toca em Pausar
        await tester.tap(find.text('Pausar'));
        await tester.pump();

        expect(find.text('Pausado'), findsOneWidget);
        expect(container.read(activeExerciseProvider).isRunning, isFalse);

        // Relógio avança durante a pausa, mas cronômetro permanece congelado
        agora = agora.add(const Duration(seconds: 30));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('01:05'), findsOneWidget);

        // Toca em Iniciar para retomar
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        expect(find.text('Em execução'), findsOneWidget);
        agora = agora.add(const Duration(seconds: 10));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('01:15'), findsOneWidget);

        // Toca em Parar
        await tester.tap(find.text('Parar'));
        await tester.pump();

        expect(find.text('Parado'), findsOneWidget);
        expect(find.text('00:00'), findsOneWidget);
        expect(container.read(activeExerciseProvider).exerciseId, isNull);
        expect(container.read(activeExerciseProvider).isRunning, isFalse);
        expect(container.read(activeExerciseProvider).elapsedSeconds, 0);
      },
    );

    testWidgets(
      'Sincroniza estado quando exercício já foi iniciado pela tela de listagem ou outro exercício está ativo',
      (WidgetTester tester) async {
        final container = criarContainer();
        final notifier = container.read(activeExerciseProvider.notifier);

        // Inicia ex-1 antes de abrir a tela de detalhes (simulando início na listagem)
        notifier.startExercise('ex-1');
        agora = agora.add(const Duration(seconds: 42));
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.theme,
              home: const ExerciseDetailScreen(exerciseId: 'ex-1'),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        // Deve refletir Em execução e 00:42 sincronizados
        expect(find.text('Em execução'), findsOneWidget);
        expect(find.text('00:42'), findsOneWidget);

        // Se outro exercício (ex-2) for iniciado, ex-1 passa a exibir Parado e 00:00
        notifier.startExercise('ex-2');
        await tester.pump();

        expect(find.text('Parado'), findsOneWidget);
        expect(find.text('00:00'), findsOneWidget);

        // Ao tocar em Iniciar na tela de ex-1, assume a execução para ex-1
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        expect(container.read(activeExerciseProvider).exerciseId, 'ex-1');
        expect(find.text('Em execução'), findsOneWidget);

        notifier.stopExercise();
      },
    );

    testWidgets(
      'Botões de ação cumprem diretrizes de acessibilidade (alvo >= 48dp, tooltips e Modo Alto Contraste)',
      (WidgetTester tester) async {
        final container = criarContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.highContrastTheme,
              home: const ExerciseDetailScreen(exerciseId: 'ex-1'),
            ),
          ),
        );
        await tester.pump();

        final iniciarFinder = find.ancestor(
          of: find.text('Iniciar'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        final pausarFinder = find.ancestor(
          of: find.text('Pausar'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        final pararFinder = find.ancestor(
          of: find.text('Parar'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );

        for (final finder in [iniciarFinder, pausarFinder, pararFinder]) {
          expect(finder, findsOneWidget);
          final size = tester.getSize(finder);
          expect(
            size.width,
            greaterThanOrEqualTo(48.0),
            reason: 'Largura do botão deve ser >= 48dp',
          );
          expect(
            size.height,
            greaterThanOrEqualTo(48.0),
            reason: 'Altura do botão deve ser >= 48dp',
          );
        }

        expect(find.byTooltip('Iniciar exercício'), findsOneWidget);
        expect(find.byTooltip('Pausar exercício'), findsOneWidget);
        expect(find.byTooltip('Parar exercício'), findsOneWidget);
        expect(find.byTooltip('Ler tela'), findsOneWidget);
      },
    );
  });
}
