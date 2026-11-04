# Memória e Aprendizados do Projeto — AtivaMente

## 📌 Contexto & Estado Atual
- **Projeto:** App Flutter para auxiliar idosos na prática de exercícios físicos (Labican/UFRN).
- **Backend:** Firebase (Authentication + Cloud Firestore).
- **Stack:** Flutter 3.47.1-stable, Riverpod 3.x, `go_router` 17.x, `flutter_tts`.
- **Branches:** `main` (produção) e `dev` (desenvolvimento).
- **Iterações:** Ciclos quinzenais de 15 dias (2 semanas), encerrados às sextas-feiras com reunião de alinhamento às 17:00.
- **Status:** Sprint 3 encerrada em 02/10/2026. Sprint 4 iniciada em 02/10/2026.

## 🧠 Aprendizados & Regras do Projeto
- **Terminal e Shell Oficial:**
  - O terminal oficial no Ubuntu é o **Zsh** (`~/.zshrc`) com Oh My Zsh e Powerlevel10k. Variáveis de ambiente, paths (`$HOME/.asdf/shims`, `$HOME/.local/bin`) e comandos interativos devem considerar o `.zshrc`.
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
- **Gestão de Issues e Pull Requests:**
  - **Sempre** preencher e manter atualizadas as **labels** e a **milestone** correspondente tanto nas issues quanto nos pull requests criados ou modificados, preservando a rastreabilidade da sprint.

## 🏛️ Decisões de Arquitetura & Entregas
- **US06 / PR #23 (Perfil Completo):** Implementado por Nathan Lopes (`@nlopesr`) e mesclado em `dev`. Adiciona máscaras automáticas (`MaskTextInputFormatter`), validações biométricas (data, telefone, peso 20-300kg, altura 0.50-2.50m) e exibição reativa dos dados no perfil.
- **Resolução de Conflitos no `pubspec.yaml`:** Sempre preservar as dependências atualizadas do Firebase vindas da branch `dev`.

## 🗺️ PRs & Pendências Ativas (Em Fila para Revisão)
1. **[PR #58](https://github.com/labican-ufrn/ativamente/pull/58):** `feat(ci): configura SonarQube com sonar-project.properties e pipeline de CI (#36)` (Taciano Silva / Revisor: @nlopesr / Merge: @LuizFelixDev ou @Icaro-Nonato / Sprint 4).
2. **[PR #30](https://github.com/labican-ufrn/ativamente/pull/30):** `Feat/detalhes exercicio` (Tomé Arcanjo - US08).
3. **[PR #32](https://github.com/labican-ufrn/ativamente/pull/32):** `feat: adiciona nível de intensidade (1-10) aos exercícios` (Taciano Silva).
4. **[PR #31](https://github.com/labican-ufrn/ativamente/pull/31):** `feat: Ativar o botão de Alto Contraste #27` (Luiz Felix).
5. **[PR #33](https://github.com/labican-ufrn/ativamente/pull/33):** `feat: implementa controle e cronômetro de exercício em execução` (Nathan Lopes - US11).

## 📋 Demandas e Pautas para a Próxima Reunião
1. **Identificação e Login por Nome vs. E-mail ([Issue #21](https://github.com/labican-ufrn/ativamente/issues/21)):**
   - **Problema registrado:** O login com o nome do usuário (ex.: "Taciano Silva") falha porque o Firebase Authentication opera nativamente com e-mail/senha (`signInWithEmailAndPassword`), enquanto a tela de login (`login_screen.dart`) exibe o rótulo "Usuário" e hint "Email ou Nome", induzindo o idoso a digitar o nome.
   - **Pauta para a reunião:** Definir se o login será simplificado/unificado exclusivamente para **E-mail** (ajustando os rótulos da UI) ou se será implementada uma busca prévia no Firestore (`Pessoas`) para mapear nome/username para o e-mail correspondente.
   - **Status:** Decisão postergada para alinhamento na próxima reunião de equipe.

2. **Formalização e Fechamento da [Issue #20](https://github.com/labican-ufrn/ativamente/issues/20):**
   - Confirmar se a padronização no padrão cinza do tema (`surfaceContainerLow` aplicada no PR #42 + teste de widget adicionado) é a definitiva para encerramento formal da issue.
