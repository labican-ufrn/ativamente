import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_academia/models/exercicio.dart';
import 'package:app_academia/providers/active_exercise_provider.dart';
import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/workout/exercise_detail_screen.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late DateTime agora;
  late List<String> textosLidosPeloTts;
  late int chamadasProviderTts;
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
        userDataProvider.overrideWith((ref) => Stream.value(null)),
        exerciciosProvider.overrideWith(
          (ref) => Stream.value([testExercicio, outroExercicio]),
        ),
        readScreenProvider.overrideWith((ref, text) {
          chamadasProviderTts++;
          return () {
            textosLidosPeloTts.add(text);
          };
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Finder encontrarBotao(String rotulo) {
    return find.ancestor(
      of: find.text(rotulo),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
  }

  setUp(() {
    agora = DateTime(2026, 10, 30, 10, 0, 0);
    textosLidosPeloTts = [];
    chamadasProviderTts = 0;
  });

  group('ExerciseDetailScreen - Controle de Execução (US11 / Issue #52)', () {
    testWidgets(
      'Permite iniciar, pausar, retomar e parar o exercício, validando estado habilitado e TTS sob demanda',
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

        // No início: Iniciar habilitado, Pausar e Parar desabilitados
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Iniciar')).enabled,
          isTrue,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Pausar')).enabled,
          isFalse,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Parar')).enabled,
          isFalse,
        );

        // Toca em Iniciar
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        expect(find.text('Em execução'), findsOneWidget);
        expect(container.read(activeExerciseProvider).exerciseId, 'ex-1');
        expect(container.read(activeExerciseProvider).isRunning, isTrue);

        // Em execução: Iniciar desabilitado, Pausar e Parar habilitados
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Iniciar')).enabled,
          isFalse,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Pausar')).enabled,
          isTrue,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Parar')).enabled,
          isTrue,
        );

        // Avança 65 segundos no relógio e verifica que o TTS não foi instanciado nos ticks
        expect(chamadasProviderTts, 0);
        agora = agora.add(const Duration(seconds: 65));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('01:05'), findsOneWidget);
        expect(container.read(activeExerciseProvider).elapsedSeconds, 65);
        expect(chamadasProviderTts, 0);

        // Toca em "Ler tela" e verifica que o TTS lê o status e o tempo atualizados
        await tester.tap(find.byTooltip('Ler tela'));
        await tester.pump();

        expect(textosLidosPeloTts, hasLength(1));
        expect(textosLidosPeloTts.single, contains('Status: Em execução'));
        expect(textosLidosPeloTts.single, contains('Tempo decorrido: 01:05'));

        // Toca em Pausar
        await tester.tap(find.text('Pausar'));
        await tester.pump();

        expect(find.text('Pausado'), findsOneWidget);
        expect(container.read(activeExerciseProvider).isRunning, isFalse);

        // Quando pausado: botão exibe "Retomar" habilitado, Pausar desabilitado e Parar habilitado
        expect(find.text('Retomar'), findsOneWidget);
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Retomar')).enabled,
          isTrue,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Pausar')).enabled,
          isFalse,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Parar')).enabled,
          isTrue,
        );

        // Relógio avança durante a pausa, mas cronômetro permanece congelado
        agora = agora.add(const Duration(seconds: 30));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('01:05'), findsOneWidget);

        // Toca em Retomar
        await tester.tap(find.text('Retomar'));
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
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Iniciar')).enabled,
          isTrue,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Pausar')).enabled,
          isFalse,
        );
        expect(
          tester.widget<ButtonStyleButton>(encontrarBotao('Parar')).enabled,
          isFalse,
        );
        expect(container.read(activeExerciseProvider).exerciseId, isNull);
        expect(container.read(activeExerciseProvider).isRunning, isFalse);
        expect(container.read(activeExerciseProvider).elapsedSeconds, 0);
      },
    );

    testWidgets(
      'Sincroniza estado quando exercício já foi iniciado na listagem e pede confirmação antes de substituir outro exercício ativo',
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

        // Ao tocar em Iniciar na tela de ex-1 enquanto ex-2 está ativo, pede confirmação
        await tester.tap(find.text('Iniciar'));
        await tester.pumpAndSettle();

        expect(find.text('Trocar exercício em execução?'), findsOneWidget);

        // Cancelar mantém ex-2 ativo
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(container.read(activeExerciseProvider).exerciseId, 'ex-2');
        expect(find.text('Parado'), findsOneWidget);

        // Confirmar substitui ex-2 por ex-1
        await tester.tap(find.text('Iniciar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(container.read(activeExerciseProvider).exerciseId, 'ex-1');
        expect(find.text('Em execução'), findsOneWidget);

        notifier.stopExercise();
      },
    );

    testWidgets(
      'Cumpre diretrizes de acessibilidade (meetsGuideline de contraste, alvo de toque e matchesSemantics)',
      (WidgetTester tester) async {
        final semanticsHandle = tester.ensureSemantics();
        final container = criarContainer();

        try {
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

          // Diretrizes oficiais do flutter_test para contraste e alvos de toque
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

          // Semântica do status: possui liveRegion ativo
          expect(
            tester.getSemantics(find.text('Parado')),
            matchesSemantics(
              label: 'Parado',
              isLiveRegion: true,
              hasEnabledState: false,
            ),
          );

          // Semântica do cronômetro: rótulo único e SEM liveRegion
          expect(
            tester.getSemantics(find.bySemanticsLabel('Tempo decorrido: 00:00')),
            matchesSemantics(
              label: 'Tempo decorrido: 00:00',
              isLiveRegion: false,
            ),
          );

          // Semântica dos botões: rótulo único sem repetição do Tooltip
          expect(
            tester.getSemantics(encontrarBotao('Iniciar')),
            matchesSemantics(
              label: 'Iniciar',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction: true,
            ),
          );
          expect(
            tester.getSemantics(encontrarBotao('Pausar')),
            matchesSemantics(
              label: 'Pausar',
              isButton: true,
              hasEnabledState: true,
              isEnabled: false,
            ),
          );
          expect(
            tester.getSemantics(encontrarBotao('Parar')),
            matchesSemantics(
              label: 'Parar',
              isButton: true,
              hasEnabledState: true,
              isEnabled: false,
            ),
          );
        } finally {
          semanticsHandle.dispose();
        }
      },
    );
  });
}
