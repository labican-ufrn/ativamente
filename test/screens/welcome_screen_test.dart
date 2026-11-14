import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/auth/welcome_screen.dart';
import 'package:app_academia/theme.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> lidos;

  Future<void> pumpWelcome(WidgetTester tester, {ThemeData? theme}) async {
    lidos = [];
    final container = novoContainer(
      overrides: [
        readScreenProvider.overrideWith(
          (ref, text) =>
              () => lidos.add(text),
        ),
      ],
    );
    await pumpTelaComRouter(
      tester,
      rotaInicial: '/',
      tela: const WelcomeScreen(),
      container: container,
      theme: theme,
    );
  }

  testWidgets('exibe nome do app, saudação e os dois botões', (tester) async {
    await pumpWelcome(tester);

    expect(find.text('AtivaMente'), findsOneWidget);
    expect(find.text('Seja bem-vindo(a)!'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Criar conta'), findsOneWidget);
  });

  testWidgets('botão Entrar navega para /login', (tester) async {
    await pumpWelcome(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text(rotuloRota('/login')), findsOneWidget);
  });

  testWidgets('botão Criar conta navega para /register', (tester) async {
    await pumpWelcome(tester);

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text(rotuloRota('/register')), findsOneWidget);
  });

  testWidgets('botão Ler tela lê o conteúdo da tela via TTS', (tester) async {
    await pumpWelcome(tester);

    await tester.tap(find.byTooltip('Ler tela'));
    await tester.pump();

    expect(lidos, hasLength(1));
    expect(lidos.single, contains('Seja bem-vindo'));
    expect(lidos.single, contains('Botão Entrar'));
  });

  testWidgets('ícone Ler tela usa a cor primária do tema em alto contraste', (
    tester,
  ) async {
    await pumpWelcome(tester, theme: AppTheme.highContrastTheme);

    final botao = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.volume_up),
    );
    final icone = botao.icon as Icon;
    expect(icone.color, AppTheme.highContrastTheme.colorScheme.primary);
    expect(icone.size, greaterThanOrEqualTo(32));
  });
}
