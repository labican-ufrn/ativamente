import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_academia/providers/accessibility_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('highContrastProvider inicia como false se nada foi salvo', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(highContrastProvider), false);
  });

  test('highContrastProvider inicia como true se salvo como true', () async {
    SharedPreferences.setMockInitialValues({
      HighContrastNotifier.keyHighContrast: true,
    });
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(highContrastProvider), true);
  });

  test('setHighContrast altera estado e persiste no SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(highContrastProvider), false);

    await container.read(highContrastProvider.notifier).setHighContrast(true);

    expect(container.read(highContrastProvider), true);
    expect(prefs.getBool(HighContrastNotifier.keyHighContrast), true);

    await container.read(highContrastProvider.notifier).setHighContrast(false);

    expect(container.read(highContrastProvider), false);
    expect(prefs.getBool(HighContrastNotifier.keyHighContrast), false);
  });
}
