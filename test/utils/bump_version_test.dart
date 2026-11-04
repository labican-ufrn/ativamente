import 'package:flutter_test/flutter_test.dart';
import '../../tool/bump_version.dart';

void main() {
  group('SemVerInfo', () {
    test('faz o parse correto de formato com e sem build number', () {
      final v1 = SemVerInfo.parse('0.1.0+1');
      expect(v1, isNotNull);
      expect(v1!.major, equals(0));
      expect(v1.minor, equals(1));
      expect(v1.patch, equals(0));
      expect(v1.build, equals(1));
      expect(v1.semVer, equals('0.1.0'));
      expect(v1.fullVersion, equals('0.1.0+1'));
      expect(v1.tagName, equals('v0.1.0'));

      final v2 = SemVerInfo.parse('1.2.3');
      expect(v2, isNotNull);
      expect(v2!.major, equals(1));
      expect(v2.minor, equals(2));
      expect(v2.patch, equals(3));
      expect(v2.build, equals(1)); // default 1 quando omitido
    });

    test('rejeita formatos inválidos retornando null', () {
      expect(SemVerInfo.parse('invalido'), isNull);
      expect(SemVerInfo.parse('1.0'), isNull);
      expect(SemVerInfo.parse('v1.0.0'), isNull);
    });

    test('incremento de patch incrementa patch e build', () {
      final current = SemVerInfo(major: 0, minor: 1, patch: 0, build: 1);
      final next = current.bump('patch');

      expect(next.major, equals(0));
      expect(next.minor, equals(1));
      expect(next.patch, equals(1));
      expect(next.build, equals(2));
      expect(next.fullVersion, equals('0.1.1+2'));
      expect(next.tagName, equals('v0.1.1'));
    });

    test('incremento de minor incrementa minor, zera patch e incrementa build', () {
      final current = SemVerInfo(major: 0, minor: 1, patch: 4, build: 5);
      final next = current.bump('minor');

      expect(next.major, equals(0));
      expect(next.minor, equals(2));
      expect(next.patch, equals(0));
      expect(next.build, equals(6));
      expect(next.fullVersion, equals('0.2.0+6'));
      expect(next.tagName, equals('v0.2.0'));
    });

    test('incremento de major incrementa major, zera minor e patch, e incrementa build', () {
      final current = SemVerInfo(major: 0, minor: 5, patch: 2, build: 10);
      final next = current.bump('major');

      expect(next.major, equals(1));
      expect(next.minor, equals(0));
      expect(next.patch, equals(0));
      expect(next.build, equals(11));
      expect(next.fullVersion, equals('1.0.0+11'));
      expect(next.tagName, equals('v1.0.0'));
    });

    test('permite manter build number com flag keepBuild', () {
      final current = SemVerInfo(major: 0, minor: 1, patch: 0, build: 3);
      final next = current.bump('patch', keepBuild: true);

      expect(next.patch, equals(1));
      expect(next.build, equals(3));
      expect(next.fullVersion, equals('0.1.1+3'));
    });

    test('permite definir versão explícita customizada', () {
      final current = SemVerInfo(major: 0, minor: 1, patch: 0, build: 1);
      final next = current.bump('0.3.0+10');

      expect(next.major, equals(0));
      expect(next.minor, equals(3));
      expect(next.patch, equals(0));
      expect(next.build, equals(10));
      expect(next.fullVersion, equals('0.3.0+10'));
    });

    test('lança FormatException ao passar alvo inválido', () {
      final current = SemVerInfo(major: 0, minor: 1, patch: 0, build: 1);
      expect(() => current.bump('banana'), throwsA(isA<FormatException>()));
    });
  });
}
