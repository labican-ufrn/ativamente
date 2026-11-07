import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/home/home_screen.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> lidos;

  Future<void> pumpHome(WidgetTester tester, {String nome = 'Maria'}) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    lidos = [];
    final container = novoContainer(
      overrides: [
        userDisplayNameProvider.overrideWithValue(nome),
        readScreenProvider.overrideWith(
          (ref, text) =>
              () => lidos.add(text),
        ),
      ],
    );
    await pumpTelaComRouter(
      tester,
      rotaInicial: '/home',
      tela: const HomeScreen(),
      container: container,
      empilhar: false,
    );
  }

  testWidgets('exibe o nome do usuário e os três cartões de treino', (
    tester,
  ) async {
    await pumpHome(tester, nome: 'Dona Maria');

    expect(find.text('Dona Maria'), findsOneWidget);
    expect(find.text('Treinos em\nCasa'), findsOneWidget);
    expect(find.text('Treinos na\nRua'), findsOneWidget);
    expect(find.text('Treinos\nSugeridos'), findsOneWidget);
  });

  testWidgets('cartão Treinos em Casa navega para /workout', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Treinos em\nCasa'));
    await tester.pumpAndSettle();

    expect(find.text(rotuloRota('/workout')), findsOneWidget);
  });

  testWidgets('cartões ainda não implementados não navegam', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Treinos na\nRua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Treinos\nSugeridos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('aba Perfil navega para /profile; Início permanece na Home', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text(rotuloRota('/profile')), findsOneWidget);
  });

  testWidgets('botão Ler tela lê as opções da Home', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Ler tela'));
    await tester.pump();

    expect(lidos.single, contains('Tela inicial'));
    expect(lidos.single, contains('Treinos em Casa'));
  });
}
