import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_academia/theme.dart';

/// Rotas do app que podem ser destino de navegação nos testes.
const rotasDoApp = [
  '/',
  '/login',
  '/register',
  '/home',
  '/workout',
  '/profile',
  '/edit-profile',
  '/add-user',
];

/// Texto exibido pelas rotas de destino substitutas.
String rotuloRota(String path) => 'rota:$path';

/// Monta [tela] em [rotaInicial] dentro de um GoRouter real. As demais rotas
/// exibem apenas `rota:<path>`, permitindo verificar `context.go`/`push`/`pop`
/// sem montar as outras telas.
///
/// Por padrão a tela é empilhada (`push`) sobre `/` para que `context.pop()`
/// tenha para onde voltar.
Future<GoRouter> pumpTelaComRouter(
  WidgetTester tester, {
  required String rotaInicial,
  required Widget tela,
  required ProviderContainer container,
  ThemeData? theme,
  bool empilhar = true,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final router = GoRouter(
    initialLocation: empilhar ? '/' : rotaInicial,
    routes: [
      for (final path in {...rotasDoApp, rotaInicial})
        GoRoute(
          path: path,
          builder: (context, state) => path == rotaInicial
              ? tela
              : Scaffold(body: Text(rotuloRota(path))),
        ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: theme ?? AppTheme.theme,
        routerConfig: router,
      ),
    ),
  );
  if (empilhar && rotaInicial != '/') {
    // push() só completa quando a rota empilhada é removida (pop); aguardá-lo
    // travaria o teste. O pumpAndSettle abaixo já espera a navegação terminar.
    unawaited(router.push(rotaInicial));
  }
  await tester.pumpAndSettle();
  return router;
}

/// Cria um ProviderContainer descartado ao fim do teste.
ProviderContainer novoContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}
