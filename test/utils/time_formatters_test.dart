import 'package:flutter_test/flutter_test.dart';
import 'package:app_academia/core/utils/time_formatters.dart';

void main() {
  group('formatarSegundos', () {
    test('formata zero segundos como 00:00', () {
      expect(formatarSegundos(0), equals('00:00'));
    });

    test('trata valores negativos retornando 00:00', () {
      expect(formatarSegundos(-5), equals('00:00'));
    });

    test('formata valores abaixo de um minuto com zero à esquerda', () {
      expect(formatarSegundos(9), equals('00:09'));
      expect(formatarSegundos(59), equals('00:59'));
    });

    test('formata minutos e segundos corretamente', () {
      expect(formatarSegundos(60), equals('01:00'));
      expect(formatarSegundos(65), equals('01:05'));
      expect(formatarSegundos(125), equals('02:05'));
      expect(formatarSegundos(599), equals('09:59'));
      expect(formatarSegundos(600), equals('10:00'));
    });

    test('formata tempos superiores a uma hora mantendo padrão MM:SS', () {
      expect(formatarSegundos(3600), equals('60:00'));
      expect(formatarSegundos(3665), equals('61:05'));
    });
  });
}
