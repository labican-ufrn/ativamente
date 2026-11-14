import 'package:flutter_test/flutter_test.dart';
import '../../tool/convert_analyzer_to_sonar.dart';

void main() {
  group('SonarIssueConverter', () {
    final converter = SonarIssueConverter(baseDir: '/home/user/project');

    test('normaliza caminhos absolutos para relativos', () {
      expect(
        converter.toRelativePath('/home/user/project/lib/main.dart'),
        equals('lib/main.dart'),
      );
      expect(
        converter.toRelativePath(r'\home\user\project\lib\screens\home.dart'),
        equals('lib/screens/home.dart'),
      );
      expect(
        converter.toRelativePath('./lib/main.dart'),
        equals('lib/main.dart'),
      );
    });

    test('mapeia severidades e tipos corretamente', () {
      expect(converter.mapSeverity('ERROR'), equals('CRITICAL'));
      expect(converter.mapSeverity('WARNING'), equals('MAJOR'));
      expect(converter.mapSeverity('INFO'), equals('MINOR'));

      expect(
        converter.mapType('ERROR', 'some_syntax_error', null),
        equals('BUG'),
      );
      expect(
        converter.mapType('INFO', 'avoid_security_vulnerability', null),
        equals('VULNERABILITY'),
      );
      expect(
        converter.mapType('INFO', 'prefer_const_constructors', 'LINT'),
        equals('CODE_SMELL'),
      );
    });

    test('converte saída JSON do dart analyze', () {
      const jsonInput = '''
      {
        "version": 1,
        "diagnostics": [
          {
            "code": "prefer_const_constructors",
            "severity": "INFO",
            "type": "LINT",
            "location": {
              "file": "/home/user/project/lib/main.dart",
              "range": {
                "start": { "line": 15, "column": 8 },
                "end": { "line": 15, "column": 20 }
              }
            },
            "problemMessage": "Use const constructors where possible."
          }
        ]
      }
      ''';

      final result = converter.convert(jsonInput);
      expect(result['issues'], isA<List>());
      final issues = result['issues'] as List;
      expect(issues.length, equals(1));

      final issue = issues.first as Map<String, dynamic>;
      expect(issue['engineId'], equals('dart-analyzer'));
      expect(issue['ruleId'], equals('prefer_const_constructors'));
      expect(issue['severity'], equals('MINOR'));
      expect(issue['type'], equals('CODE_SMELL'));

      final primaryLoc = issue['primaryLocation'] as Map<String, dynamic>;
      expect(primaryLoc['filePath'], equals('lib/main.dart'));
      expect(primaryLoc['message'], equals('Use const constructors where possible.'));

      final textRange = primaryLoc['textRange'] as Map<String, dynamic>;
      expect(textRange['startLine'], equals(15));
      expect(textRange['endLine'], equals(15));
      expect(textRange['startColumn'], equals(8));
      expect(textRange['endColumn'], equals(20));
    });

    test('converte saída JSON do dart analyze mesmo com texto antes do JSON', () {
      const noisyJsonInput = '''
      Analyzing ativamente...
      {
        "version": 1,
        "diagnostics": [
          {
            "code": "avoid_print",
            "severity": "INFO",
            "type": "LINT",
            "location": {
              "file": "/home/user/project/lib/utils.dart",
              "range": {
                "start": { "line": 5, "column": 3 },
                "end": { "line": 5, "column": 10 }
              }
            },
            "problemMessage": "Avoid print."
          }
        ]
      }
      ''';

      final result = converter.convert(noisyJsonInput);
      final issues = result['issues'] as List;
      expect(issues.length, equals(1));
      final issue = issues.first as Map<String, dynamic>;
      expect(issue['ruleId'], equals('avoid_print'));
      expect((issue['primaryLocation'] as Map)['filePath'], equals('lib/utils.dart'));
    });

    test('converte saída de texto simples do flutter analyze', () {
      const textInput = '''
Analyzing ativamente...
  info • Use 'const' with the constructor to improve performance • lib/theme.dart:25:12 • prefer_const_constructors
  warning • Avoid using web libraries directly • lib/utils.dart:5:1 • avoid_web_libraries_in_flutter
2 issues found.
      ''';

      final result = converter.convert(textInput);
      final issues = result['issues'] as List;
      expect(issues.length, equals(2));

      final first = issues[0] as Map<String, dynamic>;
      expect(first['ruleId'], equals('prefer_const_constructors'));
      expect(first['severity'], equals('MINOR'));
      expect(first['type'], equals('CODE_SMELL'));
      expect((first['primaryLocation'] as Map)['filePath'], equals('lib/theme.dart'));

      final second = issues[1] as Map<String, dynamic>;
      expect(second['ruleId'], equals('avoid_web_libraries_in_flutter'));
      expect(second['severity'], equals('MAJOR'));
      expect((second['primaryLocation'] as Map)['filePath'], equals('lib/utils.dart'));
    });
  });
}
