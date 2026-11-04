import 'dart:io';

/// Script utilitário para gerenciamento de Versionamento Semântico (SemVer) no AtivaMente.
///
/// Uso:
///   dart run tool/bump_version.dart [patch|minor|major]
///   dart run tool/bump_version.dart 0.2.0
///   dart run tool/bump_version.dart patch --dry-run
///
/// Regras:
///   - patch: 0.1.0+1 -> 0.1.1+2 (correções de bugs retrocompatíveis)
///   - minor: 0.1.0+1 -> 0.2.0+2 (novas funcionalidades retrocompatíveis)
///   - major: 0.1.0+1 -> 1.0.0+2 (mudanças com quebra de compatibilidade)
void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printUsage();
    exit(0);
  }

  final dryRun = args.contains('--dry-run');
  final keepBuild = args.contains('--keep-build');
  final noChangelog = args.contains('--no-changelog');

  // Filtra flags
  final positionalArgs =
      args.where((arg) => !arg.startsWith('--') && !arg.startsWith('-')).toList();

  if (positionalArgs.isEmpty) {
    stderr.writeln('Erro: tipo de incremento (patch, minor, major) ou versão alvo obrigatório.');
    _printUsage();
    exit(1);
  }

  final target = positionalArgs.first.toLowerCase();

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Erro: pubspec.yaml não encontrado no diretório atual.');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    stderr.writeln('Erro: não foi possível localizar o campo "version:" em pubspec.yaml.');
    exit(1);
  }

  int major = int.parse(match.group(1)!);
  int minor = int.parse(match.group(2)!);
  int patch = int.parse(match.group(3)!);
  int build = int.parse(match.group(4) ?? '1');

  final currentVersion = '$major.$minor.$patch+$build';

  if (target == 'patch') {
    patch += 1;
  } else if (target == 'minor') {
    minor += 1;
    patch = 0;
  } else if (target == 'major') {
    major += 1;
    minor = 0;
    patch = 0;
  } else {
    // Tenta interpretar como versão semântica explícita (ex: 0.2.0 ou 0.2.0+2)
    final customRegex = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');
    final customMatch = customRegex.firstMatch(target);
    if (customMatch == null) {
      stderr.writeln('Erro: formato de versão inválido "$target". Use patch, minor, major ou X.Y.Z.');
      exit(1);
    }
    major = int.parse(customMatch.group(1)!);
    minor = int.parse(customMatch.group(2)!);
    patch = int.parse(customMatch.group(3)!);
    if (customMatch.group(4) != null) {
      build = int.parse(customMatch.group(4)!);
    }
  }

  if (!keepBuild && target != 'explicit-with-build') {
    build += 1;
  }

  final newSemVer = '$major.$minor.$patch';
  final newFullVersion = '$newSemVer+$build';

  stdout.writeln('----------------------------------------------------');
  stdout.writeln('🔖 Atualização de Versionamento Semântico (SemVer)');
  stdout.writeln('----------------------------------------------------');
  stdout.writeln('Versão atual:  $currentVersion');
  stdout.writeln('Nova versão:   $newFullVersion (Tag sugerida: v$newSemVer)');
  stdout.writeln('Modo Dry Run:  ${dryRun ? "SIM (nada será alterado)" : "NÃO"}');
  stdout.writeln('----------------------------------------------------');

  if (dryRun) {
    stdout.writeln('Dry-run concluído. Nenhuma alteração gravada.');
    return;
  }

  // Atualiza pubspec.yaml
  final updatedPubspec = pubspecContent.replaceFirst(
    versionRegex,
    'version: $newFullVersion',
  );
  pubspecFile.writeAsStringSync(updatedPubspec);
  stdout.writeln('✔ pubspec.yaml atualizado com sucesso.');

  // Atualiza CHANGELOG.md se existir
  final changelogFile = File('CHANGELOG.md');
  if (!noChangelog && changelogFile.existsSync()) {
    final changelogContent = changelogFile.readAsStringSync();
    final today = _formatDate(DateTime.now());

    if (changelogContent.contains('## [Unreleased]')) {
      final releaseSection =
          '## [Unreleased]\n\n---\n\n## [$newSemVer] - $today';
      final updatedChangelog = changelogContent.replaceFirst(
        '## [Unreleased]',
        releaseSection,
      );
      changelogFile.writeAsStringSync(updatedChangelog);
      stdout.writeln('✔ CHANGELOG.md atualizado com a seção [$newSemVer] - $today.');
    } else {
      stdout.writeln('ℹ Marcador "## [Unreleased]" não encontrado no CHANGELOG.md. Seção não adicionada.');
    }
  }

  stdout.writeln('\nPróximos passos recomendados (GitFlow):');
  stdout.writeln('  1. git checkout -b release/v$newSemVer');
  stdout.writeln('  2. git add pubspec.yaml CHANGELOG.md');
  stdout.writeln('  3. git commit -m "chore(release): prepara versao v$newSemVer"');
  stdout.writeln('  4. Abra o PR para a branch `main`');
  stdout.writeln('  5. Após o merge na `main`, crie a tag: git tag -a v$newSemVer -m "Release v$newSemVer"');
  stdout.writeln('  6. Envie a tag: git push origin v$newSemVer');
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

void _printUsage() {
  stdout.writeln('''
Uso: dart run tool/bump_version.dart <incremento|versao> [opcoes]

Argumentos:
  patch             Incrementa PATCH (0.1.0 -> 0.1.1) e build number (+1)
  minor             Incrementa MINOR (0.1.0 -> 0.2.0, patch=0) e build number (+1)
  major             Incrementa MAJOR (0.1.0 -> 1.0.0, minor=patch=0) e build number (+1)
  <X.Y.Z>           Define uma versão semântica específica

Opções:
  --dry-run         Apenas simula o incremento sem alterar arquivos
  --keep-build      Não incrementa o build number (mantém o valor atual)
  --no-changelog    Não atualiza o arquivo CHANGELOG.md
  -h, --help        Exibe esta mensagem de ajuda
''');
}
