import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_academia/screens/auth/login_screen.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tela de Login possui campos de Usuário e Senha com estilos padronizados (Issue #20)', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
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
    expect(userField.decoration?.fillColor, AppTheme.theme.colorScheme.surfaceContainerLow);
    expect(passwordField.decoration?.fillColor, AppTheme.theme.colorScheme.surfaceContainerLow);

    // Estilos de texto consistentes usando tokens do tema
    expect(userField.style?.color, AppTheme.theme.colorScheme.onSurface);
    expect(passwordField.style?.color, AppTheme.theme.colorScheme.onSurface);
    expect(userField.style?.fontSize, 18);
    expect(passwordField.style?.fontSize, 18);

    // O cursor e foco no campo de usuário funcionam perfeitamente
    await tester.tap(textFields.first);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus, isNotNull);
  });
}
