# AGENTS.md — Instruções para Agentes de Código (AtivaMente)

Diretrizes para agentes de IA (e pessoas) trabalhando neste repositório. **Toda a documentação, comentários de commit e comunicação do projeto são escritos em português brasileiro (PT-BR).**

## Sobre o projeto

- App Flutter (Dart) para auxiliar idosos na prática de exercícios físicos — Labican/UFRN.
- Backend: Firebase (Authentication + Cloud Firestore).
- Stack: Flutter 3.x, Riverpod, go_router, flutter_tts.
- Documentação do domínio: [`docs/user-stories.md`](docs/user-stories.md), [`docs/plano-sprints.md`](docs/plano-sprints.md), modelo conceitual da API em [`ativamente-api/docs/modelo-conceitual.md`](https://github.com/labican-ufrn/ativamente-api/blob/dev/docs/modelo-conceitual.md).

## Skills oficiais para Dart e Flutter

Instale e utilize as skills mantidas pelas equipes oficiais de Dart, Flutter e Firebase antes de implementar tarefas. As skills são copiadas para `.agents/skills/` (já listado no `.gitignore` — não deve ser commitado).

> Requer Node.js/npx instalado. Use o flag `--agent universal` para funcionar com qualquer agente de código e `--yes` para não pedir confirmação.

### Instalação (todas de uma vez)

```bash
npx skills add dart-lang/skills --skill '*' --agent universal --yes
npx skills add flutter/agent-plugins --agent universal --yes
npx skills add firebase/agent-skills --agent universal --yes
```

### Dart — [dart-lang/skills](https://github.com/dart-lang/skills)

```bash
npx skills add dart-lang/skills --skill '*' --agent universal --yes
```

Skills relevantes: `dart-add-unit-test`, `dart-run-static-analysis`, `dart-fix-runtime-errors`, `dart-resolve-package-conflicts`, `dart-write-documentation`, `dart-collect-coverage`.

### Flutter — [flutter/agent-plugins](https://github.com/flutter/agent-plugins)

Instruções de instalação por agente: https://docs.flutter.dev/ai/get-started

```bash
npx skills add flutter/agent-plugins --agent universal --yes
```

Skills relevantes: `flutter-apply-architecture-best-practices`, `flutter-setup-declarative-routing` (go_router já em uso), `flutter-add-widget-test`, `flutter-add-integration-test`, `flutter-fix-layout-issues`, `flutter-build-responsive-layout`, `flutter-implement-json-serialization`.

> Ao escrever código, siga as convenções dessas skills (arquitetura em camadas UI/Logic/Data, testes com `WidgetTester`, navegação declarativa).

### Firebase — [firebase/agent-skills](https://github.com/firebase/agent-skills)

```bash
npx skills add firebase/agent-skills --agent universal --yes
```

Skills relevantes: `firebase-basics`, `firebase-auth-basics`, `firebase-firestore`, `firebase-hosting-basics`, `firebase-security-rules-auditor`.

> Use estas skills ao mexer em Authentication, Firestore, regras de segurança e deploy/hosting.

### Skills essenciais para este projeto

Das 37 skills instaladas, as recomendadas para o dia a dia deste app (Flutter + Firebase + Riverpod) são:

- **Qualidade/análise:** `dart-run-static-analysis`, `dart-fix-runtime-errors`
- **Arquitetura/código:** `flutter-apply-architecture-best-practices`, `flutter-implement-json-serialization` (modelos `fromJson`/`toJson`), `flutter-setup-declarative-routing` (go_router)
- **Testes:** `flutter-add-widget-test`, `dart-add-unit-test`
- **Firebase:** `firebase-basics`, `firebase-auth-basics`, `firebase-firestore`, `firebase-security-rules-auditor`

As demais (ex.: `*-ffi-*`, `dart-use-ffigen`, `dart-migrate-to-checks-package`, `firebase-data-connect`, `firebase-crashlytics`, `firebase-remote-config-basics`, `firebase-hosting-basics`, `extension-to-functions-codebase`, `xcode-project-setup`, `flutter-setup-localization`) não se aplicam ao escopo atual (sem FFI, sem Data Connect/Crashlytics/Hosting/Remote Config, app em PT-BR sem i18n, alvo Android/Web) e podem ser ignoradas.

## Fluxo Git (GitFlow)

```
main   ← produção (releases; proteção: apenas via PR a partir de dev)
dev    ← desenvolvimento (features são integradas aqui)
feature/<nome>  ← branches de funcionalidade, criados a partir de dev
bugfix/<nome>   ← correções encontradas em desenvolvimento
hotfix/<nome>   ← correções urgentes direto de main
release/<versão> ← preparação de release (dev → main)
```

Regras:
1. Nunca commitar diretamente em `main` ou `dev`.
2. Branches de trabalho: `feature/nome-da-funcionalidade` (kebab-case, sem acentos).
3. PRs apontam para `dev`; releases fazem merge de `dev` → `main`.
4. Manter PRs pequenos e revisáveis.

## Conventional Commits (obrigatório)

Formato: `<tipo>: <descrição curta no imperativo, PT-BR>`

| Tipo | Uso |
|---|---|
| `feat` | nova funcionalidade |
| `fix` | correção de bug |
| `docs` | documentação |
| `test` | testes |
| `refactor` | refatoração sem mudança de comportamento |
| `style` | formatação/estilo |
| `chore` | tarefas de build/tooling |
| `ci` | pipelines de integração contínua |

Exemplos:
```
feat: adiciona tela de detalhe do exercício
fix: corrige botão voltar da tela de treino
docs: atualiza user stories da sprint 2
```

Escopo opcional: `feat(workout): ...`. Referencie issues no corpo (`Refs: #12` ou `Closes #12`).

## Comandos essenciais

```bash
flutter pub get                 # instalar dependências
flutter analyze                 # análise estática (obrigatório antes do PR)
dart fix --apply                # corrigir problemas mecânicos de lint
flutter test                    # testes unitários/widget
flutter test --coverage         # rodar testes e coletar cobertura (gera coverage/lcov.info)
flutter run -d web-server --web-port=3000 --dart-define-from-file=.env  # executar em debug com emuladores
flutter build apk               # build Android
flutter build web               # build Web
```

## Regras de qualidade

1. `flutter analyze` sem erros/warnings novos e testes passando (`flutter test`) antes de abrir PR.
2. Novas telas devem: cobrir o botão "Ler tela" (TTS), respeitar tema (`lib/theme.dart`) e usar textos grandes/legíveis (público idoso).
3. Navegação: usar `context.go()` para trocar de seção e `context.push()` para empilhar telas de detalhe — nunca misturar `pop()` após `go()`.
4. Sem segredos/chaves no repositório (configurações Firebase ficam nos arquivos gerados pelo `flutterfire configure`, que não devem conter chaves privadas).
5. Modelos em `lib/models/` seguem o padrão `fromJson`/`toJson`; providers em `lib/providers/` com Riverpod.
6. Toda documentação nova em PT-BR dentro de `docs/`.

## Templates

- Issues: `.github/ISSUE_TEMPLATE/` — usar o template adequado (tarefa/feature ou bug).
- Milestones: uma milestone por sprint (15 dias, início/fim às sextas) — ver `docs/plano-sprints.md`.
