import 'dart:io';

/// Representa a versão calculada com SemVer e Build Number.
class SemVerInfo {
  final int major;
  final int minor;
  final int patch;
  final int build;

  const SemVerInfo({
    required this.major,
    required this.minor,
    required this.patch,
    required this.build,
  });

  String get semVer => '$major.$minor.$patch';
  String get fullVersion => '$semVer+$build';
  String get tagName => 'v$semVer';

  static SemVerInfo? parse(String text) {
    final regex = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');
    final match = regex.firstMatch(text.trim());
    if (match == null) return null;

    return SemVerInfo(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
      build: match.group(4) != null ? int.parse(match.group(4)!) : 1,
    );
  }

  SemVerInfo bump(String target, {bool keepBuild = false}) {
    int newMajor = major;
    int newMinor = minor;
    int newPatch = patch;
    int newBuild = keepBuild ? build : build + 1;

    switch (target.toLowerCase()) {
      case 'patch':
        newPatch += 1;
        break;
      case 'minor':
        newMinor += 1;
        newPatch = 0;
        break;
      case 'major':
        newMajor += 1;
        newMinor = 0;
        newPatch = 0;
        break;
      default:
        final explicit = SemVerInfo.parse(target);
        if (explicit == null) {
          throw FormatException(
            'Formato inválido "$target". Use patch, minor, major ou X.Y.Z.',
          );
        }
        return explicit;
    }

    return SemVerInfo(
      major: newMajor,
      minor: newMinor,
      patch: newPatch,
      build: newBuild,
    );
  }
}

/// Script utilitário para gerenciamento de Versionamento Semântico (SemVer) no AtivaMente.
void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printUsage();
    exit(0);
  }

  final dryRun = args.contains('--dry-run');
  final keepBuild = args.contains('--keep-build');
  final noChangelog = args.contains('--no-changelog');

  final positionalArgs =
      args.where((arg) => !arg.startsWith('--') && !arg.startsWith('-')).toList();

  if (positionalArgs.isEmpty) {
    stderr.writeln('Erro: tipo de incremento (patch, minor, major) ou versão alvo obrigatório.');
    _printUsage();
    exit(1);
  }

  final target = positionalArgs.first;

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Erro: pubspec.yaml não encontrado no diretório atual.');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*([^\r\n]+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    stderr.writeln('Erro: campo "version:" não localizado em pubspec.yaml.');
    exit(1);
  }

  final currentRaw = match.group(1)!.trim();
  final current = SemVerInfo.parse(currentRaw);
  if (current == null) {
    stderr.writeln('Erro: formato da versão atual "$currentRaw" em pubspec.yaml é inválido.');
    exit(1);
  }

  final SemVerInfo next;
  try {
    next = current.bump(target, keepBuild: keepBuild);
  } catch (e) {
    stderr.writeln('Erro: $e');
    exit(1);
  }

  stdout.writeln('----------------------------------------------------');
  stdout.writeln('🔖 Atualização de Versionamento Semântico (SemVer)');
  stdout.writeln('----------------------------------------------------');
  stdout.writeln('Versão atual:  ${current.fullVersion}');
  stdout.writeln('Nova versão:   ${next.fullVersion} (Tag sugerida: ${next.tagName})');
  stdout.writeln('Modo Dry Run:  ${dryRun ? "SIM (nada será alterado)" : "NÃO"}');
  stdout.writeln('----------------------------------------------------');

  if (dryRun) {
    stdout.writeln('Dry-run concluído. Nenhuma alteração gravada.');
    return;
  }

  // Atualiza pubspec.yaml
  final updatedPubspec = pubspecContent.replaceFirst(
    versionRegex,
    'version: ${next.fullVersion}',
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
          '## [Unreleased]\n\n---\n\n## [${next.semVer}] - $today';
      final updatedChangelog = changelogContent.replaceFirst(
        '## [Unreleased]',
        releaseSection,
      );
      changelogFile.writeAsStringSync(updatedChangelog);
      stdout.writeln('✔ CHANGELOG.md atualizado com a seção [${next.semVer}] - $today.');
    }
  }

  stdout.writeln('\nPróximos passos recomendados (GitFlow Simplificado 0.x.y):');
  stdout.writeln('  1. git add pubspec.yaml CHANGELOG.md');
  stdout.writeln('  2. git commit -m "chore(release): prepara versao ${next.tagName}"');
  stdout.writeln('  3. Abra o PR de `dev` para a branch `main`');
  stdout.writeln('  4. Após o merge na `main`, crie a tag: git tag -a ${next.tagName} -m "Release ${next.tagName}"');
  stdout.writeln('  5. Envie a tag: git push origin ${next.tagName}');
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
