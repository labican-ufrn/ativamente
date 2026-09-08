# User Stories — AtivaMente (App Flutter)

> **Fontes:** [`docs/modelo-conceitual.md`](https://github.com/labican-ufrn/ativamente-api/blob/dev/docs/modelo-conceitual.md) (API Django) + análise de código do repositório (`lib/`) + feedback de teste manual em dispositivo (21/08/2026).
>
> **Contexto técnico atual:** app Flutter com Firebase (Auth + Firestore), Riverpod, go_router e flutter_tts. Os modelos seguem o *design frontend original* (`Pessoa`, `Categoria`/`Tipo` com ícone, FKs diretas), ainda não alinhados 1:1 ao modelo conceitual do backend (N:N, `Equipamento`, flags de métricas).

**Legenda de status:**

| Ícone | Significado |
|---|---|
| ✅ | Implementada e validada |
| 🐞 | Implementada com bug reportado em teste |
| 🔜 | Planejada em sprint (ver `docs/plano-sprints.md`) |
| 💤 | Backlog — sem sprint definida |

---

## Épico 1 — Autenticação e Contas

### US01 — Cadastrar conta
**Como** visitante, **quero** criar uma conta informando nome, e-mail e senha, **para** acessar o app.

- **Status:** ✅ Implementada
- **Origem:** modelo conceitual (`Usuario`) · tela inicial "Criar conta"
- **Critérios de aceite:**
  - [x] Cadastro cria usuário no Firebase Auth e documento na coleção `Pessoas`.
  - [x] Após cadastro, usuário é redirecionado para a Home autenticado.
  - [x] Erros (e-mail inválido/duplicado, senha fraca) exibidos via SnackBar e em card vermelho de alerta no topo do formulário (acessibilidade para idosos).

### US02 — Autenticar-se
**Como** usuário cadastrado, **quero** entrar com e-mail e senha, **para** ter acesso às telas privadas do app.

- **Status:** ✅ Implementada
- **Origem:** modelo conceitual (`Usuario`) · issue #56/#46 (frontend)
- **Critérios de aceite:**
  - [x] Login com e-mail/senha válido leva à Home.
  - [x] Rotas privadas (`/home`, `/workout`, `/profile`, `/add-user`) redirecionam não autenticados para `/` (guarda em `lib/routes.dart`).
  - [x] Senha oculta com alternância visibilidade.
- **Observações:** campo aceita "Email ou Nome" na UI, mas o login funciona apenas via E-mail. Discussão aberta na Issue #21 para restringir e-mail de forma definitiva e adequar o rótulo para 'E-mail'.

### US03 — Encerrar sessão
**Como** usuário autenticado, **quero** sair da conta, **para** impedir uso do app por outra pessoa no mesmo aparelho.

- **Status:** ✅ Implementada
- **Critérios de aceite:**
  - [x] Botão "Sair" no Perfil desautentica e retorna à tela inicial.
  - [x] Rotas privadas tornam-se inacessíveis após logout.

### US04 — Admin cadastra usuários com papel
**Como** administrador, **quero** criar contas de Usuário Comum, Personal Trainer ou Administrador, **para** provisionar acesso sem precisar do aparelho de cada pessoa.

- **Status:** ✅ Implementada
- **Origem:** feedback do projeto · `lib/screens/admin/add_user_screen.dart`
- **Critérios de aceite:**
  - [x] Seção Admin visível somente para `role == 'admin'`.
  - [x] Criação usa App Firebase secundária (admin permanece logado).
  - [x] Validações: nome/e-mail obrigatórios, senha mínima de 6 caracteres.

---

## Épico 2 — Perfil do Usuário

### US05 — Ver meus dados em todas as telas *(atualizada pelo teste)*
**Como** usuário autenticado, **quero** ver meu nome carregado corretamente na Home e no Perfil (e onde mais for exibido), **para** confirmar que estou na minha conta.

- **Status:** 🐞 Bug reportado — *nome não carrega; também não aparece nas demais telas*
- **Prioridade:** Alta (Sprint 1)
- **Critérios de aceite:**
  - [ ] Nome real do usuário logado aparece na Home (cabeçalho) e no Perfil.
  - [ ] Causa raiz diagnosticada e documentada (hipóteses: documento ausente em `Pessoas` para contas criadas fora do fluxo de registro; regras de segurança do Firestore bloqueando leitura; doc com campos vazios).
  - [ ] Fallback robusto: se o documento não existir, exibir `displayName` ou e-mail do Firebase Auth (nunca travar em loading nem mostrar erro bruto).
  - [ ] Contas criadas antes da lógica de registro recebem documento `Pessoas` automaticamente (migração/on-demand).
- **Evidência atual:** `home_screen.dart:45-59` e `profile_screen.dart:37-48` consomem `userDataProvider`; quando o snapshot não existe exibem `'Usuário'`/fallback genérico. Nenhuma outra tela exibe identidade.

### US06 — Editar meus dados biométricos
**Como** usuário, **quero** editar altura, peso, data de nascimento e telefone, **para** manter meu perfil atualizado.

- **Status:** 🔜 Sprint 4 (Issue #13 / PR #23)
- **Critérios de aceite / Regras de negócio:**
  - [ ] **Data de Nascimento:**
    - Formato com máscara automática (`DD/MM/AAAA`) e limite máximo de 10 caracteres.
    - Validação contra datas de calendário inexistentes (ex.: 31/02/2020) e bloqueio de datas no futuro.
    - Validação de idade mínima obrigatória de 14 anos.
  - [ ] **Telefone com DDD:**
    - Indicação explícita de formato no rótulo/hint (`(XX) XXXXX-XXXX`).
    - Máscara automática e limite de caracteres (máximo 15 caracteres para `(XX) XXXXX-XXXX`).
    - Exibição do número de telefone também na tela de visualização do Perfil (`ProfileScreen`).
  - [ ] **Peso e Altura:**
    - Aceita decimais com ponto ou vírgula (normalizar com `replaceAll(',', '.')`).
    - Altura aceita em metros (0,50 a 2,50) ou em centímetros (50 a 250), normalizando para metros antes de persistir.
  - [ ] **Acessibilidade & TTS:**
    - Botão "Ler tela" (TTS) presente na AppBar da tela de edição.
    - Fontes legíveis (fontSize >= 18) e áreas de toque ampliadas para o público idoso.

---

## Épico 3 — Catálogo de Exercícios

### US07 — Listar exercícios por categoria
**Como** usuário, **quero** listar exercícios separados nas categorias Coração e Músculo, **para** escolher o que treinar.

- **Status:** ✅ Implementada (versão simplificada)
- **Origem:** modelo conceitual (`Exercicio`, `CategoriaExercicio`) · issues #57/#65/#66
- **Critérios de aceite:**
  - [x] Abas Coração/Músculo filtram a lista vinda da coleção `Exercicios` (stream em tempo real).
  - [x] Lista vazia mostra mensagem amigável.
- **Observações:** usa `Categoria`/`Tipo` simplificadas do design original (nome+ícone), não as tabelas N:N do backend.

### US08 — Ver detalhe do exercício *(nova)*
**Como** usuário, **quero** tocar em um exercício da lista e ver sua descrição detalhada, **para** saber como executá-lo corretamente.

- **Status:** 🔜 Sprint 2
- **Prioridade:** Alta
- **Origem:** feedback 21/08/2026 (*"ao listar os exercícios... não encaminha para nenhum local — deveria ir para a descrição detalhada, que no futuro terá vídeo/gif animado"*)
- **Critérios de aceite:**
  - [ ] Tap no card abre tela de detalhe (rota dedicada) com nome, descrição, categoria e tipo.
  - [ ] Espaço reservado (widget) para mídia futura (vídeo/GIF), sem quebrar layout hoje.
  - [ ] Botão voltar da tela de detalhe funciona (retorna à lista mantendo categoria selecionada).

### US09 — Seed oficial do catálogo *(atualizada)*
**Como** administrador, **quero** popular o Firestore com os exercícios oficiais (Manual do Idoso) e as contas de teste (admin/trainer), **para** validar o app com dados reais.

- **Status:** 🔜 Sprint 1 (re-executar no novo projeto Labican)
- **Critérios de aceite:**
  - [ ] Seed idempotente (não duplicar exercícios/contas ao rodar 2×).
  - [ ] Executável pelo admin pela tela de Perfil (fluxo atual mantido).
  - [ ] Descrições padronizadas permitindo extrair tempo previsto (ex.: `"10 min"`, `"3x de 10 repetições"`).

---

## Épico 4 — Execução de Treino ⭐

### US10 — Navegação correta na tela de treino *(correção)*
**Como** usuário, **quero** que o botão voltar da tela de treino retorne à Home, **para** navegar sem depender da barra inferior.

- **Status:** 🔜 Sprint 1
- **Prioridade:** Alta
- **Origem:** feedback 21/08/2026 (*"o botão voltar não funciona, precisa clicar no ícone Home"*). Causa raiz identificada: `workout_screen.dart:65` usa `context.pop()`, mas a chegada à rota foi via `context.go('/workout')`, que substitui a pilha do go_router — não há nada para "pop".
- **Critérios de aceite:**
  - [ ] Voltar (seta do AppBar) retorna à Home preservando estado de autenticação.
  - [ ] Padrão adotado documentado: `go` para troca de seção, `push` para empilhar detalhes.

### US11 — Marcar exercício em execução *(nova)*
**Como** usuário, **quero** indicar qual exercício estou realizando agora, **para** o app controlar o tempo daquele exercício específico.

- **Status:** 🔜 Sprint 2
- **Prioridade:** Alta
- **Origem:** feedback 21/08/2026 (*"tem que ter uma forma para marcar qual exercício está sendo realizado naquele momento"*)
- **Critérios de aceite:**
  - [ ] Ao selecionar um exercício (detalhe ou lista), ele fica marcado visualmente como "Em execução".
  - [ ] O cronômetro inicia automaticamente ao marcar o exercício.
  - [ ] Somente um exercício em execução por vez; iniciar outro finaliza/marca o anterior.
  - [ ] Usuário consegue interromper/cancelar a execução.

### US12 — Tempo previsto com alertas *(nova)*
**Como** usuário idoso, **quero** ser avisado quando o tempo previsto do exercício terminar e lembrado (com som e aviso visual) caso continue além do previsto, **para** não exceder a duração segura recomendada.

- **Status:** 🔜 Sprint 3
- **Prioridade:** Alta
- **Origem:** feedback 21/08/2026 — *"o play de tempo deve iniciar e, quando passar o tempo previsto, o app deve perguntar se o exercício foi concluído"*; *"se passar muito tempo do previsto (ex.: previsão total >10 min), devem aparecer notificações visuais e com som para lembrar de dar stop"*. O tempo previsto virá **inicialmente da descrição** do exercício.
- **Critérios de aceite:**
  - [ ] Duração prevista extraída da `descricao` (minutos; repetições usam estimativa configurável por exercício).
  - [ ] Ao atingir o tempo previsto: diálogo perguntando "Você concluiu este exercício?" (Sim / Ainda não).
  - [ ] Se continuar após o previsto: alertas recorrentes **visuais + sonoros** (intervalos configuráveis) lembrando de parar.
  - [ ] Alertas respeitam acessibilidade (alto contraste, texto grande, TTS opcional lendo o aviso).
  - [ ] Cronômetro continua exibindo o tempo decorrido total.

### US13 — Registrar conclusão do exercício *(nova)*
**Como** usuário, **quero** que a conclusão do exercício fique registrada, **para** acompanhar o que realizei no dia (base para Progresso no futuro).

- **Status:** 🔜 Sprint 3
- **Prioridade:** Média
- **Origem:** modelo conceitual (`RegistroAtivDia` / `ExercicioRealizado.statusRealizado`)
- **Critérios de aceite:**
  - [ ] Ao confirmar conclusão, grava registro do dia no Firestore (`data`, `horaInicio`, `duracao`, referências a pessoa/exercício/treino sugerido) usando o modelo `RegistroAtivDia`.
  - [ ] Exercício marcado como realizado (indicador na lista).
  - [ ] Falha de rede tratada (retry/mensagem), sem perder o estado da sessão.

---

## Épico 5 — Acessibilidade

### US14 — Ler tela em voz alta
**Como** usuário com baixa visão, **quero** ouvir o conteúdo da tela, **para** usar o app com autonomia.

- **Status:** ✅ Implementada (`flutter_tts` pt-BR, botão de volume em todas as telas)

### US15 — Preferências de acessibilidade funcionais
**Como** usuário, **quero** configurar alto contraste, tamanho de fonte e velocidade da voz, **para** adaptar o app às minhas necessidades.

- **Status:** 💤 Backlog (UI existe como placeholder sem ação em `profile_screen.dart`)
- **Critérios de aceite (proposta):** preferências persistidas e aplicadas globalmente; velocidade da voz altera `setSpeechRate`.

---

## Backlog futuro (sem sprint definida)

| US | História | Origem |
|---|---|---|
| US16 | Treinos na Rua — lista própria de exercícios ao ar livre | Home card vazio · issue #66 · `CATEGORIA_EXERCICIO.AO_AR_LIVRE` |
| US17 | Treinos Sugeridos por nível (Iniciante/Mediano/Avançado) com último treino feito | Modelo `TreinoSugerido` (órfão) · issues #42/#43/#67 |
| US18 | Tela de Progresso/Evolução com histórico de treinos | Aba inativa · issues #26/#49/#58 |
| US19 | Notificações do sistema (título, conteúdo, data/hora) | Modelo `Notificacao` · issues #32/#33 |
| US20 | Alinhar modelos Flutter ao modelo conceitual do backend (N:N, Equipamento, flags `usa_*`, mídia estruturada) | `modelo-conceitual.md` §5 |

---

## Matriz resumo

| US | Título | Status | Sprint |
|---|---|---|---|
| US01 | Cadastrar conta | ✅ | — |
| US02 | Autenticar-se | ✅ | — |
| US03 | Encerrar sessão | ✅ | — |
| US04 | Admin cadastra usuários com papel | ✅ | — |
| US05 | Ver meus dados em todas as telas | 🐞 Bug | S1 |
| US06 | Editar dados biométricos | 💤 | Backlog |
| US07 | Listar exercícios por categoria | ✅ | — |
| US08 | Detalhe do exercício | 🔜 | S2 |
| US09 | Seed oficial do catálogo | 🔜 | S1 |
| US10 | Navegação correta na tela de treino | 🔜 | S1 |
| US11 | Marcar exercício em execução | 🔜 | S2 |
| US12 | Tempo previsto com alertas | 🔜 | S3 |
| US13 | Registrar conclusão do exercício | 🔜 | S3 |
| US14 | Ler tela em voz alta | ✅ | — |
| US15 | Preferências de acessibilidade | 💤 | Backlog |
| US16–US20 | Backlog futuro | 💤 | — |
