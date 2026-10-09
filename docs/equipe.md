# Equipe — AtivaMente

App Flutter para auxiliar idosos na realização de exercícios físicos de forma saudável e segura (Labican/UFRN).

## Docentes

| # | Nome | Papel | GitHub |
|---|------|-------|--------|
| 1 | Taciano Silva | Analista / Revisor de PR | [@tacianosilva](https://github.com/tacianosilva) |
| 2 | Flavius Gorgônio | Docente Coordenador / Testes de aceitação | [@flgorgonio](https://github.com/flgorgonio) |
| 3 | Karliane Vieira | Docente Coordenadora / Testes de aceitação | [@karlianev](https://github.com/karlianev) |
| 4 | Fabrício Vale | Docente criador da v1 | [@fabriciovale79](https://github.com/fabriciovale79) |

## Equipe de Desenvolvimento

| # | Nome | Matrícula | Papel | GitHub |
|---|------|-----------|-------|--------|
| 1 | Ícaro Nonato de Freitas | 20250031361 | Líder Técnico / Revisor de PR | [@Icaro-Nonato](https://github.com/Icaro-Nonato) |
| 2 | Marcus Vinícius de Souza Azevedo | 20250032583 | Dev | [@MViniciusCoffe](https://github.com/MViniciusCoffe) |
| 3 | Nathan Lopes Rodrigues | 20240060056 | Dev | [@nlopesr](https://github.com/nlopesr) |
| 4 | Isaac Vilton Ribeiro | 20250031512 | Dev | [@Isaac-Ribeiro](https://github.com/Isaac-Ribeiro) |
| 5 | Tomé Galileu Oliveira Arcanjo | 20240046173 | Dev | [@Tome-arcanjo](https://github.com/Tome-arcanjo) |
| 6 | Wallison Valdemiro Silvino Dias | 20250023771 | Dev | [@wallisonvsdias](https://github.com/wallisonvsdias) |
| 7 | Luiz Henrique Felix Guedes | 20240053740 | Dev | [@LuizFelixDev](https://github.com/LuizFelixDev) |

## Tarefas de estudo (Sprint 1)

Todos os membros devem concluir as duas tarefas de estudo abaixo. Ao terminar, **cada membro marca o próprio nome no checklist da issue**, usando sua própria conta GitHub:

### 1. Firebase com CRUD
Estudar Firebase seguindo tutorial oficial, conectando-se ao serviço e realizando as operações de CRUD no Cloud Firestore + autenticação por e-mail/senha.

- **Issue:** [#1 — [Estudo] Firebase — tutorial com conexão e operações de CRUD](https://github.com/labican-ufrn/ativamente/issues/1)
- **Importante:** usar projeto pessoal de teste no Firebase Console — não utilizar o projeto oficial do Labican.

### 2. Dart/Flutter com telinha conectada ao Firebase
Estudar Dart/Flutter e construir uma tela simples (formulário + lista em tempo real) acessando a mesma base Firebase dos estudos, completando o CRUD pela interface.

- **Issue:** [#2 — [Estudo] Dart/Flutter — telinha acessando a mesma base Firebase](https://github.com/labican-ufrn/ativamente/issues/2)
- Referências: `lib/providers/firestore_provider.dart`, `lib/screens/`, `lib/models/`.

## Tarefa individual — CI/CD

Documentar o passo a passo de deploy automático (CI/CD) do app Flutter com GitHub Actions + Firebase Hosting, integrado ao fluxo GitFlow (`dev` → homologação, `main` → produção).

- **Issue:** [#3 — [CI/CD] Documentar passo a passo de deploy automático do app Flutter](https://github.com/labican-ufrn/ativamente/issues/3)
- **Responsável:** a definir pela equipe.
- **Entregável:** `docs/deploy-cicd.md` + workflows em `.github/workflows/`.

## Organização do trabalho

- **Fluxo GitFlow:** branches principais `main` (produção) e `dev` (desenvolvimento); funcionalidades saem de `dev` em branches `feature/nome`.
- **Conventional Commits** obrigatório (ex.: `feat: adiciona tela de detalhe do exercício`).
- **Liderança Técnica e Permissões de Merge (a partir de 25/09/2026):**
  - **Líderes Técnicos:** Taciano Silva, Luiz Felix e Ícaro Nonato.
  - **Permissão de Merge:** Podem realizar merge em PRs nos quais não atuaram como revisores diretos (se necessário, Taciano Silva tem permissão de realizar merge em qualquer PR).
- **Reuniões e Encerramento de Iterações:**
  - Encerramento das iterações/sprints ocorre sempre às **sextas-feiras com reunião de alinhamento às 17:00**.
  - **Reunião de 02/10/2026:** presentes: Taciano, Karliane e Tomé.
- **Toda a documentação é escrita em português brasileiro.**
- Sprints de 15 dias: ver [`docs/plano-sprints.md`](plano-sprints.md).
- User Stories: ver [`docs/user-stories.md`](user-stories.md).

---

## Histórico de Entregas por Iteração (Quinzenal / 2 Iterações por linha)

| Período (Datas) | Sprint / Iterações | Resumo das Atividades e Entregas por Membro |
|---|---|---|
| **21/08 → 04/09/2026** | **Sprint 1**<br>*(Iterações 1 e 2)* | • **Nathan Lopes:** Concluiu Estudos #1 e #2 ([PR #18](https://github.com/labican-ufrn/ativamente/pull/18)). Iniciou perfil (#13).<br>• **Tomé Arcanjo:** Concluiu Estudos #1 e #2.<br>• **Ícaro Nonato:** Atuou como Tech Lead/Revisor ([PR #19](https://github.com/labican-ufrn/ativamente/pull/19), [#25](https://github.com/labican-ufrn/ativamente/pull/25), [#26](https://github.com/labican-ufrn/ativamente/pull/26)). Estudos #1/#2 pendentes.<br>• **Taciano Silva:** Setup de infraestrutura, emuladores Firebase, documentação (Sprints/US/AGENTS/README), suíte de testes (100% cobertura) e auto-seed.<br>• **Marcus Vinícius, Isaac Ribeiro, Wallison Dias, Luiz Felix:** Tarefas de estudo #1 e #2 pendentes. |
| **04/09 → 18/09/2026** | **Sprint 2**<br>*(Iterações 3 e 4)* | • **Tomé Arcanjo:** Desenvolveu tela de detalhes dos exercícios ([PR #30](https://github.com/labican-ufrn/ativamente/pull/30) / Issue [#9](https://github.com/labican-ufrn/ativamente/issues/9)).<br>• **Luiz Felix:** Desenvolveu botão de Alto Contraste ([PR #31](https://github.com/labican-ufrn/ativamente/pull/31) / Issue [#27](https://github.com/labican-ufrn/ativamente/issues/27)).<br>• **Nathan Lopes:** Desenvolveu tela e formulário de edição de perfil completo ([PR #23](https://github.com/labican-ufrn/ativamente/pull/23) / Issue [#13](https://github.com/labican-ufrn/ativamente/issues/13)).<br>• **Taciano Silva:** Refatorou seed em JSON com catálogo variado, regras da US06, botão TTS em EditProfile e nível de intensidade nos exercícios ([PR #32](https://github.com/labican-ufrn/ativamente/pull/32)). Merges do [#28](https://github.com/labican-ufrn/ativamente/pull/28) e [#29](https://github.com/labican-ufrn/ativamente/pull/29).<br>• **Ícaro Nonato:** Tech Lead/Revisor no merge dos PRs [#28](https://github.com/labican-ufrn/ativamente/pull/28) e [#29](https://github.com/labican-ufrn/ativamente/pull/29).<br>• **Marcus Vinícius:** Issue [#8](https://github.com/labican-ufrn/ativamente/issues/8) (Nome usuário) reatribuída para Luiz Felix em 25/09. |
| **18/09 → 02/10/2026** | **Sprint 3**<br>*(Iterações 5 e 6)* | • **Nathan Lopes:** Implementou o controle e cronômetro de exercício em execução em 26/09 ([PR #33](https://github.com/labican-ufrn/ativamente/pull/33) / Issue [#10](https://github.com/labican-ufrn/ativamente/issues/10)).<br>• **Isaac Ribeiro:** Corrigiu o botão voltar da tela de treino com `context.go('/home')` em 25/09 (branch `6-bug-botão-voltar...` / Issue [#6](https://github.com/labican-ufrn/ativamente/issues/6)).<br>• **Tomé Arcanjo:** Mantido PR #30 em revisão.<br>• **Luiz Felix:** Recebeu a Issue [#8](https://github.com/labican-ufrn/ativamente/issues/8) (Nome usuário) e nomeado Tech Lead/Revisor em 25/09.<br>• **Wallison Dias:** Atribuídas as Issues [#11](https://github.com/labican-ufrn/ativamente/issues/11) (Tempo previsto + alertas) e [#12](https://github.com/labican-ufrn/ativamente/issues/12) (Registro Firestore).<br>• **Marcus Vinícius:** Mantido com as Issues [#20](https://github.com/labican-ufrn/ativamente/issues/20) (Bug login) e [#3](https://github.com/labican-ufrn/ativamente/issues/3) (CI/CD deploy).<br>• **Ícaro Nonato:** Nomeado Tech Lead/Revisor a partir de 25/09.<br>• *Reunião de 02/10:* presentes: Taciano, Karliane e Tomé. |

