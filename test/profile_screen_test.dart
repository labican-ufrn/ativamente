import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_academia/providers/accessibility_provider.dart';
import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/screens/profile/profile_screen.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Switch de Modo Alto Contraste reflete estado e altera provider ao tocar', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStateProvider.overrideWith((ref) => Stream.value(null)),
        userDataProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.theme,
          home: const ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    Switch switchWidget = tester.widget<Switch>(switchFinder);
    expect(switchWidget.value, false);

    await tester.ensureVisible(switchFinder);
    await tester.pumpAndSettle();
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    switchWidget = tester.widget<Switch>(switchFinder);
    expect(switchWidget.value, true);
    expect(container.read(highContrastProvider), true);
    expect(prefs.getBool(HighContrastNotifier.keyHighContrast), true);
  });
}
