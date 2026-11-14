# Changelog

Todas as mudanças relevantes do AtivaMente são registradas neste arquivo, seguindo o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [0.1.0] - 2026-11-04

### Adicionado
- **Versionamento Semântico e Deploy:** adoção oficial de SemVer `0.1.0+1` (`pubspec.yaml`), ferramenta `tool/bump_version.dart`, pipeline `.github/workflows/release.yml` e política de deploy exclusivo pela `main` (PR #63).
- **Regras de Segurança Cloud Firestore:** `firestore.rules` em produção com controle de acesso baseado em papéis (RBAC) para `Pessoas` e leitura pública autenticada de `Exercicios` (PR #63).
- **Catálogo Oficial do Manual do Idoso (US09):** mapeamento clínico dos 12 exercícios iniciais do Manual do Idoso Ativo (`docs/catalogo-exercicios-manual.md`) e seed idempotente no projeto `ativamente-labican-ufrn` (PR #63).
- **Detalhe do Exercício (US08):** tela dedicada (`/exercise/:id`) com nome, descrição, categoria, tipo, indicador de intensidade e placeholder para mídia futura (PR #30, PR #60).
- **Controle de Execução & Cronômetro (US11):** marcação de exercício ativo via `exercicioEmExecucaoProvider`, cronômetro sincronizado por `DateTime` e botão de cancelamento/troca (PR #47, PR #60).
- **Nível de Intensidade (US21):** suporte a intensidade (1 a 10) nos modelos, seed, chips visuais na lista e filtro dinâmico com suporte a TTS (PR #32).
- **Edição de Perfil Biométrico (US06):** tela de edição de perfil com dados biométricos (altura, peso, data de nascimento e telefone), máscaras automáticas, validações de faixa biológica e TTS (PR #23).
- **Acessibilidade e Alto Contraste (US15):** suporte completo ao Modo Alto Contraste com tokens de tema semânticos, separação visual de cards e contraste WCAG AAA (PR #42).
- **Acessibilidade de Toque:** ampliação da área de toque do botão de execução na lista de exercícios para atender o público idoso (PR #50).
- **Infraestrutura e CI:** integração com SonarQube Quality Gate no GitHub Actions para análise estática contínua e cobertura de testes (PR #58).
- **Garantia de Qualidade:** matriz formal de testes de regressão e diagnóstico de causas raízes (`docs/qa-matriz-testes.md`).

### Corrigido
- **Nome de Usuário (US05):** correção do bug de exibição no cabeçalho e perfil através de precedência resiliente (`getEffectiveDisplayName`), provider síncrono e auto-criação de documentos `Pessoas` (PR #40).
- **Navegação de Retorno (US10):** substituição de `pop` por navegação declarativa `context.go('/home')` na tela de treino, evitando travamentos na pilha de rotas (PR #6).
- **Drift no Cronômetro:** cálculo do tempo decorrido utilizando timestamps de `DateTime` em vez de contagem de ticks do timer periódico (PR #47).
- **Inicialização do Seed:** reutilização de instância no setup de usuários de teste em ambiente de emulador (PR #39).
