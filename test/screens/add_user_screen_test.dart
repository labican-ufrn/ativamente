import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/admin/add_user_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FakeAuthController? auth;
  late List<String> lidos;

  Future<void> pumpAddUser(WidgetTester tester, {Object? erro}) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    lidos = [];
    auth = null;
    final container = novoContainer(
      overrides: [
        fakeAuthControllerOverride((c) => auth = c, erro: erro),
        readScreenProvider.overrideWith(
          (ref, text) =>
              () => lidos.add(text),
        ),
      ],
    );
    await pumpTelaComRouter(
      tester,
      rotaInicial: '/add-user',
      tela: const AddUserScreen(),
      container: container,
    );
  }

  Finder campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

  Future<void> preencher(WidgetTester tester) async {
    await tester.enterText(campo('Nome Completo'), ' Carlos ');
    await tester.enterText(campo('E-mail'), ' carlos@ativamente.org ');
    await tester.enterText(campo('Senha'), '123456');
  }

  testWidgets('valida campos obrigatórios e senha mínima', (tester) async {
    await pumpAddUser(tester);

    await tester.enterText(campo('Senha'), '123');
    await tester.tap(find.text('Criar Usuário'));
    await tester.pumpAndSettle();

    expect(find.text('Insira o nome'), findsOneWidget);
    expect(find.text('Insira o e-mail'), findsOneWidget);
    expect(find.text('Senha deve ter no mínimo 6 caracteres'), findsOneWidget);
    // Formulário inválido: o AuthController nem chega a ser usado.
    expect(auth?.chamadas ?? const [], isEmpty);
  });

  testWidgets('cria usuário comum por padrão e volta com mensagem de sucesso', (
    tester,
  ) async {
    await pumpAddUser(tester);

    await preencher(tester);
    await tester.tap(find.text('Criar Usuário'));
    await tester.pumpAndSettle();

    expect(auth!.chamadas.single, [
      'createSecondaryUser',
      'Carlos',
      'carlos@ativamente.org',
      '123456',
      'user',
    ]);
    expect(find.text('Usuário adicionado com sucesso!'), findsOneWidget);
    expect(find.text(rotuloRota('/')), findsOneWidget);
  });

  testWidgets('permite escolher o tipo Administrador', (tester) async {
    await pumpAddUser(tester);

    await preencher(tester);
    await tester.tap(find.text('Usuário Comum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Administrador').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar Usuário'));
    await tester.pumpAndSettle();

    expect(auth!.chamadas.single.last, 'admin');
  });

  testWidgets('erro ao criar exibe snackbar e permanece na tela', (
    tester,
  ) async {
    await pumpAddUser(tester, erro: Exception('email-already-in-use'));

    await preencher(tester);
    await tester.tap(find.text('Criar Usuário'));
    await tester.pumpAndSettle();

    expect(find.byType(AddUserScreen), findsOneWidget);
    expect(find.textContaining('Erro ao adicionar usuário'), findsOneWidget);
    // Botão volta a ficar habilitado após o erro.
    final botao = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(botao.onPressed, isNotNull);
  });

  testWidgets('botão Ler tela lê as instruções', (tester) async {
    await pumpAddUser(tester);

    await tester.tap(find.byTooltip('Ler tela'));
    await tester.pump();

    expect(lidos.single, contains('adicionar usuário'));
  });
}
