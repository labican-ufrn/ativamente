import 'dart:convert';
import 'dart:io';

/// Mapeia e converte relatórios de análise estática do Dart (JSON ou texto)
/// para o formato oficial SonarQube Generic Issue Import.
class SonarIssueConverter {
  final String baseDir;

  SonarIssueConverter({String? baseDir})
      : baseDir = _normalizePath(baseDir ?? Directory.current.path);

  static String _normalizePath(String path) {
    var normalized = path.replaceAll('\\', '/');
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  String toRelativePath(String filePath) {
    var path = filePath.replaceAll('\\', '/');
    if (path.startsWith(baseDir)) {
      path = path.substring(baseDir.length);
    }
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.startsWith('./')) {
      path = path.substring(2);
    }
    return path;
  }

  String mapSeverity(String? dartSeverity) {
    switch (dartSeverity?.toUpperCase()) {
      case 'ERROR':
        return 'CRITICAL';
      case 'WARNING':
        return 'MAJOR';
      case 'INFO':
      default:
        return 'MINOR';
    }
  }

  String mapType(String? dartSeverity, String? ruleId, String? dartType) {
    final rule = (ruleId ?? '').toLowerCase();
    if (rule.contains('security') || rule.contains('vulnerability')) {
      return 'VULNERABILITY';
    }
    if (dartSeverity?.toUpperCase() == 'ERROR' ||
        (dartType != null && dartType.toUpperCase().contains('ERROR'))) {
      return 'BUG';
    }
    return 'CODE_SMELL';
  }

  int estimateEffortMinutes(String severity, String type) {
    if (type == 'BUG') return 30;
    if (severity == 'CRITICAL' || severity == 'BLOCKER') return 20;
    if (severity == 'MAJOR') return 10;
    return 5;
  }

  Map<String, dynamic> convertDiagnosticToIssue(Map<String, dynamic> diag) {
    final code = diag['code'] as String? ?? 'dart_lint';
    final severity = diag['severity'] as String? ?? 'INFO';
    final dartType = diag['type'] as String?;
    final problemMessage =
        diag['problemMessage'] as String? ?? 'Problema de lint detectado';

    final location = diag['location'] as Map<String, dynamic>? ?? {};
    final file = location['file'] as String? ?? '';
    final range = location['range'] as Map<String, dynamic>? ?? {};
    final start = range['start'] as Map<String, dynamic>? ?? {};
    final end = range['end'] as Map<String, dynamic>? ?? {};

    final startLine = (start['line'] as num?)?.toInt() ?? 1;
    final endLine = (end['line'] as num?)?.toInt() ?? startLine;
    final startCol = (start['column'] as num?)?.toInt() ?? 1;
    final endCol = (end['column'] as num?)?.toInt() ?? startCol;

    final sonarSeverity = mapSeverity(severity);
    final sonarType = mapType(severity, code, dartType);

    final issue = <String, dynamic>{
      'engineId': 'dart-analyzer',
      'ruleId': code,
      'severity': sonarSeverity,
      'type': sonarType,
      'primaryLocation': {
        'message': problemMessage,
        'filePath': toRelativePath(file),
        'textRange': {
          'startLine': startLine,
          'endLine': endLine >= startLine ? endLine : startLine,
          'startColumn': startCol,
          'endColumn': endCol >= startCol ? endCol : startCol,
        },
      },
      'effortMinutes': estimateEffortMinutes(sonarSeverity, sonarType),
    };

    return issue;
  }

  List<Map<String, dynamic>> parseJsonReport(String jsonContent) {
    final parsed = jsonDecode(jsonContent);
    if (parsed is! Map<String, dynamic>) return [];

    final diagnostics = parsed['diagnostics'];
    if (diagnostics is! List) return [];

    final issues = <Map<String, dynamic>>[];
    for (final item in diagnostics) {
      if (item is Map<String, dynamic>) {
        issues.add(convertDiagnosticToIssue(item));
      }
    }
    return issues;
  }

  List<Map<String, dynamic>> parseTextReport(String textContent) {
    final issues = <Map<String, dynamic>>[];
    final lines = textContent.split('\n');

    // Regex para linhas: "  info • Mensagem • path/to/file.dart:10:5 • rule_code"
    final regex = RegExp(r'^\s*([a-zA-Z]+)\s*•\s*(.*?)\s*•\s*(.*?):(\d+):(\d+)\s*•\s*([a-zA-Z0-9_]+)');

    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final severity = match.group(1);
        final message = match.group(2) ?? '';
        final file = match.group(3) ?? '';
        final startLine = int.tryParse(match.group(4) ?? '1') ?? 1;
        final startCol = int.tryParse(match.group(5) ?? '1') ?? 1;
        final ruleId = match.group(6) ?? 'dart_lint';

        final sonarSeverity = mapSeverity(severity);
        final sonarType = mapType(severity, ruleId, null);

        issues.add({
          'engineId': 'dart-analyzer',
          'ruleId': ruleId,
          'severity': sonarSeverity,
          'type': sonarType,
          'primaryLocation': {
            'message': message,
            'filePath': toRelativePath(file),
            'textRange': {
              'startLine': startLine,
              'endLine': startLine,
              'startColumn': startCol,
              'endColumn': startCol + 1,
            },
          },
          'effortMinutes': estimateEffortMinutes(sonarSeverity, sonarType),
        });
      }
    }

    return issues;
  }

  Map<String, dynamic> convert(String content) {
    List<Map<String, dynamic>> issues;
    try {
      issues = parseJsonReport(content);
    } catch (_) {
      issues = parseTextReport(content);
    }
    return {'issues': issues};
  }
}

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.writeln(
      'Uso: dart run tool/convert_analyzer_to_sonar.dart [arquivo_entrada] [arquivo_saida]\n'
      'Padrão:\n'
      '  Entrada: build/analyzer-report.json\n'
      '  Saída:   build/sonar-generic-issues.json',
    );
    exit(0);
  }

  final inputPath = args.isNotEmpty ? args[0] : 'build/analyzer-report.json';
  final outputPath = args.length > 1 ? args[1] : 'build/sonar-generic-issues.json';

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Aviso: Arquivo de entrada "$inputPath" não encontrado. Gerando relatório vazio.');
    final outputFile = File(outputPath);
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync(jsonEncode({'issues': []}));
    exit(0);
  }

  final content = inputFile.readAsStringSync();
  final converter = SonarIssueConverter();
  final result = converter.convert(content);

  final outputFile = File(outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(result),
  );

  final totalIssues = (result['issues'] as List).length;
  stdout.writeln(
    '✅ [Sonar Generic Issues] Convertidas $totalIssues issues para "$outputPath".',
  );
}
