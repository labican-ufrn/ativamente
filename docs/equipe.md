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
- **Toda a documentação é escrita em português brasileiro.**
- Sprints de 15 dias: ver [`docs/plano-sprints.md`](plano-sprints.md).
- User Stories: ver [`docs/user-stories.md`](user-stories.md).
