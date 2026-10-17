# Memória e Aprendizados do Projeto — AtivaMente

## 📌 Contexto & Estado Atual
- **Projeto:** App Flutter para auxiliar idosos na prática de exercícios físicos (Labican/UFRN).
- **Backend:** Firebase (Authentication + Cloud Firestore).
- **Stack:** Flutter 3.47.1-stable, Riverpod 3.x, `go_router` 17.x, `flutter_tts`.
- **Branches:** `main` (produção) e `dev` (desenvolvimento).
- **Iterações:** Ciclos quinzenais de 15 dias (2 semanas), encerrados às sextas-feiras com reunião de alinhamento às 17:00.
- **Status:** Sprint 3 encerrada em 02/10/2026. Sprint 4 iniciada em 02/10/2026.

## 🧠 Aprendizados & Regras do Projeto
- **Liderança Técnica e Permissões de Merge (a partir de 25/09/2026):**
  - **Líderes Técnicos:** Taciano Silva, Luiz Felix e Ícaro Nonato.
  - **Permissão de Merge:** Podem realizar merge em PRs nos quais não sejam os revisores diretos (Taciano Silva tem permissão para realizar merge em qualquer PR se necessário).
- **Execução Local & Emuladores Firebase:**
  - Para testar localmente com `--dart-define-from-file=.env` (onde `USE_FIREBASE_EMULATORS=true`), o **Firebase Emulator Suite** deve estar rodando em background (`firebase emulators:start`).
  - **Portas:** Auth (`9099`), Firestore (`8080`), Hosting (`5000`), UI do Emulador (`http://localhost:4000`).
- **Padrão de Navegação (`go_router`):**
  - Usar `context.go()` para trocar de seção principal.
  - Usar `context.push()` para empilhar telas de detalhe ou formulários de edição. Usar `context.pop()` exclusivamente para retornar após um `push()`.
- **Diretrizes de Acessibilidade & UI:**
  - Todas as telas devem incluir botão de leitura de tela (TTS) com `readScreenProvider`.
  - Manter tamanho de fontes legíveis (`fontSize >= 18`) e áreas de toque ampliadas para o público idoso.

## 🏛️ Decisões de Arquitetura & Entregas
- **US06 / PR #23 (Perfil Completo):** Implementado por Nathan Lopes (`@nlopesr`) e mesclado em `dev`. Adiciona máscaras automáticas (`MaskTextInputFormatter`), validações biométricas (data, telefone, peso 20-300kg, altura 0.50-2.50m) e exibição reativa dos dados no perfil.
- **Resolução de Conflitos no `pubspec.yaml`:** Sempre preservar as dependências atualizadas do Firebase vindas da branch `dev`.

## 🗺️ PRs & Pendências Ativas (Em Fila para Revisão)
1. **[PR #30](https://github.com/labican-ufrn/ativamente/pull/30):** `Feat/detalhes exercicio` (Tomé Arcanjo - US08).
2. **[PR #32](https://github.com/labican-ufrn/ativamente/pull/32):** `feat: adiciona nível de intensidade (1-10) aos exercícios` (Taciano Silva).
3. **[PR #31](https://github.com/labican-ufrn/ativamente/pull/31):** `feat: Ativar o botão de Alto Contraste #27` (Luiz Felix).
4. **[PR #33](https://github.com/labican-ufrn/ativamente/pull/33):** `feat: implementa controle e cronômetro de exercício em execução` (Nathan Lopes - US11).
