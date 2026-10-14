import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_academia/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('highContrastTheme', () {
    test('define papeis de superficie derivados para separacao visual', () {
      final theme = AppTheme.highContrastTheme;
      final colorScheme = theme.colorScheme;

      expect(colorScheme.surfaceContainerLow, equals(const Color(0xFF1C1C1C)));
      expect(colorScheme.surfaceContainer, equals(const Color(0xFF262626)));
      expect(colorScheme.surfaceContainerHighest, equals(const Color(0xFF333333)));
      expect(colorScheme.surfaceContainerLow, isNot(equals(theme.scaffoldBackgroundColor)));
    });

    test('define cardTheme com borda de alto contraste e cor de fundo destacada', () {
      final theme = AppTheme.highContrastTheme;
      final cardTheme = theme.cardTheme;

      expect(cardTheme.color, equals(const Color(0xFF1C1C1C)));
      expect(cardTheme.shape, isA<RoundedRectangleBorder>());
      
      final border = cardTheme.shape as RoundedRectangleBorder;
      expect(border.side.color, equals(const Color(0xFFFFE600)));
      expect(border.side.width, equals(2.0));
    });

    test('define inputDecorationTheme com estilo e bordas visiveis', () {
      final theme = AppTheme.highContrastTheme;
      final inputTheme = theme.inputDecorationTheme;

      expect(inputTheme.filled, isTrue);
      expect(inputTheme.fillColor, equals(const Color(0xFF1C1C1C)));
      expect(inputTheme.hintStyle?.color, equals(const Color(0xFFCCCCCC)));
      expect(inputTheme.border, isA<OutlineInputBorder>());
    });
  });
}
