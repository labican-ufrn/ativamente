import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/routes.dart';
import 'package:app_academia/screens/auth/login_screen.dart';
import 'package:app_academia/screens/auth/welcome_screen.dart';
import 'package:app_academia/screens/home/home_screen.dart';
import 'package:app_academia/screens/workout/workout_screen.dart';
import 'package:app_academia/theme.dart';

import 'helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    User? usuario,
  }) async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(usuario)),
        userDataProvider.overrideWith((ref) => Stream.value(null)),
        exerciciosProvider.overrideWith((ref) => Stream.value(const [])),
        readScreenProvider.overrideWith((ref, text) => () {}),
      ],
    );
    addTearDown(container.dispose);
    // Garante que o estado de autenticação já foi emitido antes do router.
    container.listen(authStateProvider, (_, _) {});
    await container.read(authStateProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: AppTheme.theme,
            routerConfig: ref.watch(goRouterProvider),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('sem login, a rota inicial é a tela de boas-vindas', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('sem login, rotas protegidas redirecionam para boas-vindas', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    container.read(goRouterProvider).go('/workout');
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('sem login, a tela de login é acessível', (tester) async {
    final container = await pumpApp(tester);

    container.read(goRouterProvider).go('/login');
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('logado, abrir boas-vindas/login redireciona para a Home', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      usuario: FakeUser(uid: 'u1', email: 'maria@b.com'),
    );

    expect(find.byType(HomeScreen), findsOneWidget);

    container.read(goRouterProvider).go('/login');
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('logado, rotas protegidas abrem normalmente', (tester) async {
    final container = await pumpApp(
      tester,
      usuario: FakeUser(uid: 'u1', email: 'maria@b.com'),
    );

    container.read(goRouterProvider).go('/workout');
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutScreen), findsOneWidget);
  });
}
