import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/auth/register_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthController auth;
  late List<String> lidos;

  Future<void> pumpRegister(WidgetTester tester, {Object? erro}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    lidos = [];
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
      rotaInicial: '/register',
      tela: const RegisterScreen(),
      container: container,
    );
  }

  Future<void> preencherECadastrar(WidgetTester tester) async {
    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), '  Maria Souza  ');
    await tester.enterText(campos.at(1), ' maria@ativamente.org ');
    await tester.enterText(campos.at(2), 'segredo123');
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('exibe campos de nome, email e senha (senha oculta)', (
    tester,
  ) async {
    await pumpRegister(tester);

    expect(find.text('Criar Conta'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);

    final campos = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(campos, hasLength(3));
    expect(campos[1].keyboardType, TextInputType.emailAddress);
    expect(campos[2].obscureText, isTrue);
  });

  testWidgets('cadastro com sucesso envia dados aparados e vai para /home', (
    tester,
  ) async {
    await pumpRegister(tester);

    await preencherECadastrar(tester);

    expect(auth.chamadas.single, [
      'register',
      'Maria Souza',
      'maria@ativamente.org',
      'segredo123',
    ]);
    expect(find.text(rotuloRota('/home')), findsOneWidget);
  });

  testWidgets('erro do Firebase exibe mensagem amigável na tela e snackbar', (
    tester,
  ) async {
    await pumpRegister(
      tester,
      erro: FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Este e-mail já está cadastrado.',
      ),
    );

    await preencherECadastrar(tester);

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Este e-mail já está cadastrado.'), findsNWidgets(2));
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('erro genérico remove o prefixo "Exception: " da mensagem', (
    tester,
  ) async {
    await pumpRegister(tester, erro: Exception('Falha na conexão.'));

    await preencherECadastrar(tester);

    expect(find.text('Falha na conexão.'), findsNWidgets(2));
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('seta voltar retorna para a tela de boas-vindas', (tester) async {
    await pumpRegister(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    expect(find.text(rotuloRota('/')), findsOneWidget);
  });

  testWidgets('botão Ler tela lê as instruções do cadastro', (tester) async {
    await pumpRegister(tester);

    await tester.tap(find.byTooltip('Ler tela'));
    await tester.pump();

    expect(lidos.single, contains('Tela de Cadastro'));
  });
}
