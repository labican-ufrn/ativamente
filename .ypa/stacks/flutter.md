# Stack: Flutter / Dart — AtivaMente

Perfil de stack **local** do projeto, lido pela skill `code-review-criteria`
(`project.stack: flutter` no `.ypa/review.yml`). Complementa as regras universais da
skill; o `AGENTS.md` do repositório tem precedência sobre tudo aqui.

## Checks esperados em `checks`

| Chave | Valor no projeto |
|---|---|
| `app_check_cmd` | `flutter analyze` |
| `linter_cmd` | `flutter analyze` |
| `test_coverage_cmd` | `flutter test --coverage` |

`flutter analyze` (via `dart analyze`) **não lê de stdin** — para comparar com a base,
exporte o arquivo de `origin/<base>` para um diretório temporário e rode o linter nele,
ou rode os dois lados e compare totais. Confirme que a regra cobrada está **ativa** no
`analysis_options.yaml` antes de apontar achado (`flutter_lints 6.0.0` não ativa tudo —
ex.: `directives_ordering` está fora).

## Camadas do projeto

| Camada | Papel |
|---|---|
| `lib/models/` | entidades com `fromJson`/`toJson` (padrão do projeto) |
| `lib/providers/` | estado com Riverpod (`Provider`, `Notifier`, `StreamProvider`) |
| `lib/screens/` | UI |
| `lib/routes.dart` | composition root: **importa apenas `screens/`** |
| `lib/theme.dart` | tokens/`ThemeData` — únicos que podem declarar cor nominal |

- **`lib/routes.dart` não importa `lib/models/`** (regra 7 do `AGENTS.md`). Navegação de
  detalhe resolve **um único caminho** — a tela busca o registro por `id` no provider.
  Cuidado com `state.extra` tipado: ele força o import do modelo no router e duplica a
  resolução. Achado aqui é `[BLOQUEANTE]` (regra escrita no `AGENTS.md`).

## Tema e cor

- Cor vem de `Theme.of(context).colorScheme` ou dos tokens de `lib/theme.dart`. **Nada
  de `Colors.*` hardcoded em tela** (regra 2 do `AGENTS.md`) — `[BLOQUEANTE]`.
- O app tem **modo alto contraste** (`AppTheme.highContrastTheme`: fundo preto, destaque
  amarelo `#FFE600`). Texto/ícone sobre `colorScheme.primary` deve usar
  `colorScheme.onPrimary` — **branco sobre amarelo é ~1.27:1 e falha**.
- Alvo de contraste: AA (4.5:1 texto normal; 3:1 texto grande e componentes não-texto).
  Meça antes de afirmar; cite o valor.

## Acessibilidade (público idoso — regra 2 do `AGENTS.md`)

- **Toda tela tem o botão "Ler tela" (TTS)** via `readScreenProvider` — inclusive os
  estados `loading`, vazio e `erro`, não só o conteúdo. Ausência é `[BLOQUEANTE]`.
- Mensagem de erro é **amigável**; exceção crua vai para `debugPrint`, nunca na tela.
- Fonte legível (`fontSize >= 18`) e **áreas de toque ampliadas**.

## Navegação

- `context.go()` para trocar de seção; `context.push()` para empilhar detalhe; nunca
  `pop()` logo após `go()`. Botão "voltar" de rota de topo com `context.pop()` não faz
  nada — é o bug da issue #6.

## Riverpod

- `ref.watch` para derivar UI, `ref.read` para ação. `Notifier` com `Timer`/stream deve
  cancelar em `ref.onDispose`. `copyWith` que não consegue limpar campo opcional exige
  flag explícita — flag declarada e não usada é código morto.

## Testes

- Provider puro: teste em `ProviderContainer` (`test/providers/`). Tela nova: widget
  test de fluxo central. Cobertura: piso **60%** (`min_coverage`) — o `lcov` do Flutter
  só lista arquivos tocados pelos testes, então leia o número com essa ressalva.

## Exclusões (espelhar em `exclusions.paths` e `sonar.exclusions`)

`**/test/**`, `lib/firebase_options.dart`, `**/*.g.dart`, **/*.freezed.dart`,
`build/**`, `.dart_tool/**`.
