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

/// Issue #45 — comportamento do cronômetro ao sair da tela e reconstrução
/// da lista a cada tick.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late DateTime agora;
  DateTime relogio() => agora;

  Exercicio exercicio(String id, String nome) => Exercicio(
    id: id,
    nome: nome,
    descricao: 'Descrição de $nome',
    midia: '',
    statusRealizado: false,
    categoria: Categoria(nome: 'Coracao', icone: 'favorite'),
    tipo: Tipo(nome: 'Aeróbico', icone: 'directions_walk'),
    intensidade: 3,
  );

  final exercicios = [
    exercicio('ex-1', 'Caminhada Leve'),
    exercicio('ex-2', 'Marcha Parada'),
  ];

  ProviderContainer novoContainer() {
    final container = ProviderContainer(
      overrides: [
        nowProvider.overrideWithValue(relogio),
        exerciciosProvider.overrideWith((ref) => Stream.value(exercicios)),
        readScreenProvider.overrideWith((ref, text) => () {}),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget tela(ProviderContainer container) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: AppTheme.theme, home: const WorkoutScreen()),
  );

  /// Avança o relógio falso e deixa o Timer.periodic disparar.
  Future<void> avancar(WidgetTester tester, Duration d) async {
    agora = agora.add(d);
    await tester.pump(d);
  }

  setUp(() => agora = DateTime(2026, 1, 1, 8));

  testWidgets('tick do cronômetro atualiza o tempo sem reconstruir a lista', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = novoContainer();
    await tester.pumpWidget(tela(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Iniciar exercício').first);
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Em execução'), findsOneWidget);

    // Instâncias dos itens da lista antes do tick. Os ListTile não são
    // const: se a tela reconstruísse, seriam instâncias novas.
    final tilesAntes = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .toList();
    expect(tilesAntes, hasLength(2));

    await avancar(tester, const Duration(seconds: 1));
    await avancar(tester, const Duration(seconds: 1));
    await avancar(tester, const Duration(seconds: 1));

    expect(find.text('00:03'), findsOneWidget);

    final tilesDepois = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .toList();
    for (var i = 0; i < tilesAntes.length; i++) {
      expect(
        identical(tilesAntes[i], tilesDepois[i]),
        isTrue,
        reason: 'item $i da lista foi reconstruído por causa do tick',
      );
    }

    // Pausar muda isRunning: aí sim a lista é reconstruída (ícone muda).
    await tester.tap(find.byTooltip('Pausar exercício'));
    await tester.pump();
    expect(find.byTooltip('Pausar exercício'), findsNothing);
    expect(
      identical(
        tester.widget<ListTile>(find.byType(ListTile).first),
        tilesAntes.first,
      ),
      isFalse,
    );
    expect(find.text('00:03'), findsOneWidget);

    container.read(activeExerciseProvider.notifier).stopExercise();
  });

  testWidgets(
    'sair da tela não interrompe o cronômetro e ao voltar exibe o tempo total',
    (tester) async {
      final container = novoContainer();
      await tester.pumpWidget(tela(container));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Iniciar exercício').first);
      await tester.pump();
      await avancar(tester, const Duration(seconds: 5));
      expect(find.text('00:05'), findsOneWidget);

      // Sai da tela (equivale a context.go('/home') desmontando a WorkoutScreen).
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SizedBox()),
        ),
      );
      expect(find.byType(WorkoutScreen), findsNothing);

      await avancar(tester, const Duration(seconds: 60));

      final estado = container.read(activeExerciseProvider);
      expect(estado.exerciseId, 'ex-1');
      expect(estado.isRunning, isTrue);
      expect(estado.elapsedSeconds, 65);

      // Volta para a tela: tempo total e exercício ainda marcado.
      await tester.pumpWidget(tela(container));
      await tester.pumpAndSettle();
      expect(find.text('01:05'), findsOneWidget);
      expect(find.text('Em execução'), findsOneWidget);
      expect(find.byTooltip('Pausar exercício'), findsOneWidget);

      container.read(activeExerciseProvider.notifier).stopExercise();
    },
  );
}
