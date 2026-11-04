# Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [Unreleased]

### Adicionado
- Preparação inicial para novas funcionalidades da Sprint atual.

---

## [0.1.0] - 2026-11-04

### Adicionado
- Estrutura base do aplicativo Flutter com arquitetura em camadas (UI, Logic, Data).
- Integração com Firebase Authentication (login e cadastro com e-mail/senha).
- Integração com Cloud Firestore para gerenciamento de perfil e treinos.
- Catálogo de exercícios físicos categorizados para o público idoso.
- Suporte a acessibilidade com síntese de voz (TTS - *Text to Speech*) com botão "Ler tela".
- Tema adaptado com alto contraste e fontes ampliadas para melhor legibilidade.
- Pipeline de integração contínua (CI) com validação estática e Quality Gate no SonarQube.
- Roteamento declarativo com `go_router`.
- Gerenciamento de estado reativo com Riverpod.
- Script e documentação de versionamento semântico e releases (`tool/bump_version.dart`).
