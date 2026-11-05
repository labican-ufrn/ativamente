import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_academia/models/exercicio.dart';
import 'package:app_academia/models/pessoa.dart';
import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/workout/edit_exercise_screen.dart';
import 'package:app_academia/screens/workout/exercise_detail_screen.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late List<String> textosLidos;
  late List<({String id, Map<String, dynamic> dados})> atualizacoes;
  Object? erroAoSalvar;

  final exercicio = Exercicio(
    id: 'ex-1',
    codigo: 'ex-1',
    nome: 'Caminhada Leve',
    descricao: 'Caminhe em ritmo confortável por 10 minutos.',
    midia: 'https://exemplo.com/video.mp4',
    statusRealizado: true,
    intensidade: 3,
    categoria: Categoria(nome: 'Coracao', icone: 'favorite'),
    tipo: Tipo(nome: 'Cardio', icone: 'directions_run'),
  );

  Pessoa pessoa(String role) => Pessoa(id: 'u1', nome: 'Fulano', role: role);

  /// Monta o app com GoRouter: '/workout' é a tela de origem e a rota alvo
  /// é empilhada com `push`, como na navegação real.
  Future<void> abrir(
    WidgetTester tester, {
    required String role,
    String inicio = '/edit-exercise/ex-1',
  }) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/workout',
      routes: [
        GoRoute(
          path: '/workout',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push(inicio),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/exercise/:id',
          builder: (context, state) =>
              ExerciseDetailScreen(exerciseId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/edit-exercise/:id',
          builder: (context, state) =>
              EditExerciseScreen(exerciseId: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDataProvider.overrideWith((ref) => Stream.value(pessoa(role))),
          exerciciosProvider.overrideWith((ref) => Stream.value([exercicio])),
          atualizarExercicioProvider.overrideWithValue((id, dados) async {
            if (erroAoSalvar != null) throw erroAoSalvar!;
            atualizacoes.add((id: id, dados: dados));
          }),
          readScreenProvider.overrideWith((ref, text) {
            return () => textosLidos.add(text);
          }),
        ],
        child: MaterialApp.router(theme: AppTheme.theme, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    textosLidos = [];
    atualizacoes = [];
    erroAoSalvar = null;
  });

  group('EditExerciseScreen', () {
    testWidgets('pré-carrega os valores atuais do exercício', (tester) async {
      await abrir(tester, role: 'trainer');

      expect(
        find.widgetWithText(TextFormField, 'Caminhada Leve'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          TextFormField,
          'Caminhe em ritmo confortável por 10 minutos.',
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'https://exemplo.com/video.mp4'),
        findsOneWidget,
      );
      expect(find.text('3 — Leve'), findsOneWidget);
      expect(find.text('Coracao'), findsOneWidget);
      expect(find.text('Cardio'), findsOneWidget);
    });

    testWidgets('usuário sem papel de trainer/admin não vê o formulário', (
      tester,
    ) async {
      await abrir(tester, role: 'user');

      expect(
        find.text('Você não tem permissão para editar exercícios.'),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('admin também pode editar', (tester) async {
      await abrir(tester, role: 'admin');
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('exercício inexistente mostra mensagem de não encontrado', (
      tester,
    ) async {
      await abrir(
        tester,
        role: 'trainer',
        inicio: '/edit-exercise/inexistente',
      );
      expect(find.text('Exercício não encontrado.'), findsOneWidget);
    });

    testWidgets(
      'salva via update sem campos imutáveis e confirma com SnackBar',
      (tester) async {
        await abrir(tester, role: 'trainer');

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Caminhada Leve'),
          '  Caminhada Moderada  ',
        );
        await tester.tap(find.text('Salvar alterações'));
        await tester.pumpAndSettle();

        expect(atualizacoes, hasLength(1));
        final salvo = atualizacoes.single;
        expect(salvo.id, 'ex-1');
        expect(salvo.dados['nome'], 'Caminhada Moderada');
        expect(salvo.dados['intensidade'], 3);
        expect(salvo.dados['categoria'], {
          'nome': 'Coracao',
          'icone': 'favorite',
        });
        expect(salvo.dados['tipo'], {
          'nome': 'Cardio',
          'icone': 'directions_run',
        });
        // Campos imutáveis (e não editáveis) nunca vão no payload.
        expect(salvo.dados.containsKey('codigo'), isFalse);
        expect(salvo.dados.containsKey('criadoEm'), isFalse);
        expect(salvo.dados.containsKey('statusRealizado'), isFalse);

        expect(find.text('Exercício atualizado com sucesso!'), findsOneWidget);
        // Voltou para a tela de origem.
        expect(find.text('Abrir'), findsOneWidget);
      },
    );

    testWidgets('altera intensidade e categoria e regrava o ícone', (
      tester,
    ) async {
      await abrir(tester, role: 'trainer');

      await tester.tap(find.text('3 — Leve'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9 — Intenso').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Coracao'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Musculo').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      final dados = atualizacoes.single.dados;
      expect(dados['intensidade'], 9);
      expect(dados['categoria'], {
        'nome': 'Musculo',
        'icone': 'fitness_center',
      });
    });

    testWidgets('nome vazio bloqueia o salvamento', (tester) async {
      await abrir(tester, role: 'trainer');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Caminhada Leve'),
        '',
      );
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome do exercício'), findsOneWidget);
      expect(atualizacoes, isEmpty);
    });

    testWidgets('URL de mídia inválida bloqueia o salvamento', (tester) async {
      await abrir(tester, role: 'trainer');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'https://exemplo.com/video.mp4'),
        'isto não é url',
      );
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      expect(find.text('Informe uma URL válida'), findsOneWidget);
      expect(atualizacoes, isEmpty);
    });

    testWidgets(
      'falha ao salvar mostra erro amigável e permite tentar de novo',
      (tester) async {
        erroAoSalvar = Exception('permission-denied detalhe técnico');
        await abrir(tester, role: 'trainer');

        await tester.tap(find.text('Salvar alterações'));
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível salvar as alterações. Tente novamente.'),
          findsOneWidget,
        );
        expect(find.textContaining('permission-denied'), findsNothing);
        // Continua na tela, com o botão habilitado novamente.
        expect(find.text('Salvar alterações'), findsOneWidget);
      },
    );

    testWidgets('botão Ler tela aciona o TTS', (tester) async {
      await abrir(tester, role: 'trainer');

      await tester.tap(find.byTooltip('Ler tela'));
      await tester.pump();

      expect(textosLidos, hasLength(1));
      expect(textosLidos.single, contains('Editar exercício'));
      expect(textosLidos.single, contains('Caminhada Leve'));
    });
  });

  group('ExerciseDetailScreen - botão Editar', () {
    testWidgets('trainer vê o botão e navega para a edição', (tester) async {
      await abrir(tester, role: 'trainer', inicio: '/exercise/ex-1');

      await tester.tap(find.byTooltip('Editar exercício'));
      await tester.pumpAndSettle();

      expect(find.text('Salvar alterações'), findsOneWidget);
    });

    testWidgets('usuário comum não vê o botão', (tester) async {
      await abrir(tester, role: 'user', inicio: '/exercise/ex-1');

      expect(find.byTooltip('Editar exercício'), findsNothing);
      expect(find.byTooltip('Ler tela'), findsOneWidget);
    });
  });
}
