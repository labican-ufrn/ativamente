import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/auth/login_screen.dart';
import 'package:app_academia/screens/auth/register_screen.dart';
import 'package:app_academia/theme.dart';

class _FakeAuthController extends AuthController {
  bool googleSignInCalled = false;
  final Object? errorToThrow;

  _FakeAuthController(
    super.ref, {
    this.errorToThrow,
  });

  @override
  Future<bool> signInWithGoogle() async {
    googleSignInCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets(
    'Tela de Login possui campos de Usuário e Senha com estilos padronizados (Issue #20)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [readScreenProvider.overrideWith((ref, text) => () {})],
          child: MaterialApp(
            theme: AppTheme.theme,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      final userField = tester.widget<TextField>(textFields.first);
      final passwordField = tester.widget<TextField>(textFields.last);

      // Ambos os campos devem ter preenchimento com a cor semântica surfaceContainerLow
      expect(userField.decoration?.filled, true);
      expect(passwordField.decoration?.filled, true);
      expect(
        userField.decoration?.fillColor,
        AppTheme.theme.colorScheme.surfaceContainerLow,
      );
      expect(
        passwordField.decoration?.fillColor,
        AppTheme.theme.colorScheme.surfaceContainerLow,
      );

      // Estilos de texto consistentes usando tokens do tema
      expect(userField.style?.color, AppTheme.theme.colorScheme.onSurface);
      expect(passwordField.style?.color, AppTheme.theme.colorScheme.onSurface);
      expect(userField.style?.fontSize, 18);
      expect(passwordField.style?.fontSize, 18);

      // O cursor e foco no campo de usuário funcionam perfeitamente
      await tester.tap(textFields.first);
      await tester.pump();
      expect(tester.binding.focusManager.primaryFocus, isNotNull);
    },
  );

  group('Botão Entrar com Google e Acessibilidade (Issue #67)', () {
    testWidgets(
      'LoginScreen exibe botão Entrar com Google acessível, lê TTS e trata erro amigável',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        final semanticsHandle = tester.ensureSemantics();
        final textosTts = <String>[];
        late _FakeAuthController fakeController;

        try {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                readScreenProvider.overrideWith((ref, text) {
                  return () => textosTts.add(text);
                }),
                authControllerProvider.overrideWith((ref) {
                  fakeController = _FakeAuthController(
                    ref,
                    errorToThrow: FirebaseAuthException(
                      code: 'account-exists-with-different-credential',
                      message:
                          'Este e-mail já está vinculado a outro método de acesso.',
                    ),
                  );
                  return fakeController;
                }),
              ],
              child: MaterialApp(
                theme: AppTheme.highContrastTheme,
                home: const LoginScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final googleBtnFinder = find.ancestor(
            of: find.text('Entrar com Google'),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          );
          expect(googleBtnFinder, findsOneWidget);

          final size = tester.getSize(googleBtnFinder);
          expect(size.height, greaterThanOrEqualTo(48.0));
          expect(size.width, greaterThanOrEqualTo(48.0));

          // Semântica única sem duplicação do Tooltip
          expect(
            tester.getSemantics(googleBtnFinder),
            matchesSemantics(
              label: 'Entrar com Google',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction: true,
            ),
          );

          // Diretrizes de acessibilidade e contraste no Modo Alto Contraste
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

          // Verifica narração TTS incluindo o botão do Google
          await tester.tap(find.byTooltip('Ler tela'));
          await tester.pump();
          expect(textosTts, hasLength(1));
          expect(textosTts.single, contains('Botão Entrar com Google'));

          // Toca no botão Entrar com Google e valida tratamento de erro amigável
          await tester.tap(googleBtnFinder);
          await tester.pumpAndSettle();

          expect(fakeController.googleSignInCalled, isTrue);
          expect(
            find.text(
              'Este e-mail já está vinculado a outro método de acesso.',
            ),
            findsWidgets,
          );
        } finally {
          semanticsHandle.dispose();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        }
      },
    );

    testWidgets(
      'RegisterScreen exibe botão Entrar com Google acessível no Modo Alto Contraste e narra no TTS',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        final semanticsHandle = tester.ensureSemantics();
        final textosTts = <String>[];
        late _FakeAuthController fakeController;

        try {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                readScreenProvider.overrideWith((ref, text) {
                  return () => textosTts.add(text);
                }),
                authControllerProvider.overrideWith((ref) {
                  fakeController = _FakeAuthController(ref);
                  return fakeController;
                }),
              ],
              child: MaterialApp(
                theme: AppTheme.highContrastTheme,
                home: const RegisterScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final googleBtnFinder = find.ancestor(
            of: find.text('Entrar com Google'),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          );
          expect(googleBtnFinder, findsOneWidget);

          final size = tester.getSize(googleBtnFinder);
          expect(size.height, greaterThanOrEqualTo(48.0));
          expect(size.width, greaterThanOrEqualTo(48.0));

          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

          await tester.tap(find.byTooltip('Ler tela'));
          await tester.pump();
          expect(textosTts.single, contains('Botão Entrar com Google'));

          await tester.tap(googleBtnFinder);
          await tester.pumpAndSettle();
          expect(fakeController.googleSignInCalled, isTrue);
        } finally {
          semanticsHandle.dispose();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        }
      },
    );
  });
}
