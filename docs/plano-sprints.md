# Plano de Sprints — AtivaMente (App Flutter)

> **Convenções:**
> - Sprint = **15 dias**, iniciando e terminando na **sexta-feira**. A sexta de fronteira concentra review da sprint anterior + planning da seguinte.
> - Tarefas dimensionadas em **1 ou 2 semanas**; cada sprint comporta ~2–3 tarefas.
> - Rastreabilidade: toda tarefa referencia User Stories (`docs/user-stories.md`) e, quando aplicável, issues do repositório.
> - Datas baseadas no calendário de 2026 (21/08/2026 é sexta).

---

## Visão geral dos milestones

| Milestone | Sprint | Período | Tema |
|---|---|---|---|
| M1 | S1 | sex 21/08 → sex 04/09/2026 | Estabilização & Infraestrutura (QA, navegação, Firebase Labican) |
| M2 | S2 | sex 04/09 → sex 18/09/2026 | Detalhe do exercício & execução marcada |
| M3 | S3 | sex 18/09 → sex 02/10/2026 | Tempo previsto, alertas acessíveis e registro de conclusão |
| M4 | S4 | sex 02/10 → sex 16/10/2026 | Consistência de perfil & QA de regressão |
| M5 | S5 | sáb 31/10 → dom 15/11/2026 | Refinamento Alfa, Acessibilidade & Gestão de Treino |
| M6 | S6 | seg 16/11 → seg 30/11/2026 | Treinos ao Ar Livre (Rua), Histórico de Evolução & Release Beta |

```mermaid
gantt
    dateFormat DD/MM
    title Roadmap AtivaMente (ago-out 2026)
    section S1 Estabilização
    T1.1 QA exploratório          :s1a, 21/08, 7d
    T1.2 Fix botão voltar         :s1b, 21/08, 7d
    T1.3 Migração Firebase        :crit, s1c, 21/08, 14d
    T1.4 Bug nome usuário         :s1d, 28/08, 7d
    section S2 Detalhe/Execução
    T2.1 Tela detalhe exercício   :s2a, 04/09, 7d
    T2.2 Execução + timer         :s2b, 11/09, 7d
    section S3 Alertas/Registro
    T3.1 Alertas tempo previsto   :crit, s3a, 18/09, 10d
    T3.2 Registro de conclusão    :s3b, 25/09, 7d
    section S4 Consistência/QA
    T4.1 Perfil completo          :s4a, 02/10, 10d
    T4.2 QA regressão + docs      :s4b, 09/10, 7d
```

---

## Sprint 1 — Estabilização & Infraestrutura (21/08 → 04/09)

**Objetivo:** app navegável sem bugs bloqueantes e rodando sobre o projeto Firebase oficial do Labican.

> **Nota sobre execução local:** A Issue #7 (Migração Firebase) é a tarefa crítica que bloqueia validação em device com o projeto oficial. No entanto, **as Issues #5, #6 e #8 podem ser desenvolvidas e testadas localmente** usando o Firebase Emulator Suite com projeto pessoal de cada desenvolvedor (veja [`docs/execucao-local.md`](execucao-local.md)). A validação final em device com o projeto oficial será feita após a conclusão da Issue #7.

### T1.1 — Teste exploratório completo do app *(1 semana)*
- **US relacionadas:** todas (insumo para priorização) · **Issue:** a criar (`docs` de teste)
- **Descrição:** percorrer todos os fluxos do app e registrar o que funciona e o que não funciona.
- **Roteiro mínimo:**
  1. Welcome → Login → Home (nome carrega? rotas protegidas?)
  2. Cadastro de conta nova → documento `Pessoas` criado?
  3. Admin: adicionar usuário nos 3 papéis; seed idempotente?
  4. Treino: abas Coração/Músculo filtram? voltar funciona? tap em exercício?
  5. Perfil: dados exibidos? logout?
  6. TTS em cada tela.
- **Dispositivos:** Android físico/emulador + Web (Chrome).
- **Entregável:** `docs/qa-matriz-testes.md` com matriz tela × funcionalidade × status (✔/✖/parcial) + evidências.
- **DoD:** matriz publicada; bugs convertidos em issues.

### T1.2 — Correção do botão voltar da tela de treino *(1 semana, paralela à T1.1)*
- **US:** US10 · **Prioridade:** Alta
- **Descrição:** substituir `context.pop()` por `context.go('/home')` em `workout_screen.dart`; revisar demais usos de pop após navegação via `go`.
- **DoD:** voltar retorna à Home; padrão de navegação (`go` vs `push`) documentado no README ou comentário de rota.

### T1.3 — Migração do Firebase para a conta oficial Labican *(2 semanas)* ⚠ crítico
- **US:** US09 · **Decisão:** projeto novo + re-seed (sem migração de dados)
- **Passos:**
  1. Criar projeto (ex.: `ativamente-labican`) na conta oficial do laboratório; convidar mantenedores como owners/editors.
  2. Ativar **Authentication (e-mail/senha)** e **Firestore** (modo produção).
  3. `flutterfire configure` logado na conta Labican → regenerar `lib/firebase_options.dart`, `android/app/google-services.json` e iOS `GoogleService-Info.plist`.
  4. Atualizar referências de `projectId` em `firebase.json` (hoje `ativamente-97e20`) e limpar cache `.firebase/hosting.*.cache`.
  5. Definir regras Firestore iniciais (usuário lê/escreve apenas o próprio doc `Pessoas/{uid}`; coleção `Exercicios` somente leitura para usuários autenticados).
  6. Rodar seed (admin/trainer + exercícios) e validar login/cadastro/lista em device real.
  7. Após validação: desativar/remover apps do projeto pessoal antigo (decisão final do responsável pela conta).
- **Riscos:** chaves antigas versionadas no histórico do git (considerar rotação); configurações de plataforma (SHA-1 Android para futuras integrações).
- **DoD:** app conectado ao projeto Labican; fluxo auth+lista validado em device; nenhum artefato apontando para `ativamente-97e20`.

### T1.4 — Diagnóstico e correção do bug do nome do usuário *(1 semana, 2ª semana da sprint)*
- **US:** US05 🐞 · **Prioridade:** Alta
- **Descrição:** investigar por que `userDataProvider` não entrega o nome (doc `Pessoas` ausente? regras bloqueando? campos vazios?), aplicar fallback (`displayName`/e-mail) e autocriação do documento quando faltante.
- **DoD:** critérios de aceite da US05 atendidos; caso de teste adicionado à matriz de QA.

### Issues de Ajuste e Discussão Adicionais (Sprint 1)
- **[Issue #20](https://github.com/labican-ufrn/ativamente/issues/20) — Inconsistência visual nos campos de login**: Identificada diferença estética entre os campos Usuário (azul/branco) e Senha (cinza/preto) no formulário de login. Planejada correção para padronizar todos os campos com estilo cinza consistente em conformidade com o tema do app.
- **[Issue #21](https://github.com/labican-ufrn/ativamente/issues/21) — Discussão de identificação de login (E-mail vs Username)**: Discussão aberta para simplificar o acesso de usuários idosos unificando o login exclusivamente por E-mail (substituindo a terminologia vaga de "Usuário").
- **[Issue #22](https://github.com/labican-ufrn/ativamente/issues/22) — Versionar o arquivo skills-lock.json**: Tarefa administrativa de infraestrutura para adicionar o arquivo de lock de customizações das skills dos agentes de IA ao Git, garantindo consistência de tooling entre os desenvolvedores.

---

## Sprint 2 — Detalhe do Exercício & Execução Marcada (04/09 → 18/09)

### T2.1 — Tela de detalhe do exercício *(1 semana)*
- **US:** US08 · **Prioridade:** Alta
- **Escopo:** rota `/exercise/:id`; layout com placeholder de mídia (vídeo/GIF futuro), nome, descrição, categoria/tipo; navegação via `push` (voltar preserva aba selecionada).
- **DoD:** tap no card abre detalhe; voltar funcional; TTS cobre a nova tela.

### T2.2 — Intensidade do exercício: modelo, seed, UI, TTS e testes *(1 semana)*
- **US:** US21 · **Prioridade:** Alta
- **Escopo:** adicionar campo `intensidade` (1-10) ao modelo `Exercicio` com validação; atualizar `exercises.json` com valores por exercício; criar helpers `rotuloIntensidade`/`corIntensidade`/`intensityChip` em `lib/core/utils/intensity.dart`; adicionar tokens de cor no tema; exibir `ActionChip` clicável na lista de treino com filtro persistente por intensidade; TTS dinâmico narrando o filtro ativo; testes unitários em `test/models/exercicio_test.dart`.
- **DoD:** `flutter analyze` limpo; testes passam; filtro funciona e persiste ao trocar abas; TTS narra corretamente.

### T2.3 — Marcação de exercício em execução + timer automático *(1–2 semanas)*
- **US:** US11 · **Prioridade:** Alta
- **Escopo:** estado global (Riverpod) de "exercício em execução"; indicador visual na lista/detalhe; cronômetro inicia ao marcar; um exercício por vez; opção de cancelar.
- **Dependência:** T2.1.
- **DoD:** critérios da US11; estado sobrevive a troca de aba dentro da sessão.

---

## Sprint 3 — Tempo Previsto, Alertas & Registro (18/09 → 02/10)

### T3.1 — Tempo previsto + diálogo de conclusão + alertas sonoros/visuais *(~1,5–2 semanas)* ⚠ crítico
- **US:** US12 · **Prioridade:** Alta
- **Escopo:**
  - Parser da `descricao` ("X min", "Nx de Y repetições") para duração prevista; estimativa configurável por exercício quando for por repetição.
  - Ao atingir o previsto: diálogo "Você concluiu este exercício?" (Sim / Ainda não).
  - Se continuar além do previsto: lembretes recorrentes **visuais + sonoros** em intervalos configuráveis (ex.: a cada 2 min), pensados para idosos (texto grande, som claro, opcionalmente narrados via TTS).
- **Risco:** parse impreciso de descrições livres → mitigação: padronizar seed (T1.3/US09) e prever campo estruturado no futuro (US20).
- **DoD:** cenários "dentro do tempo" e "tempo excedido" demonstrados em device.

### T3.2 — Registro de conclusão no Firestore *(1 semana)*
- **US:** US13 · **Prioridade:** Média
- **Escopo:** gravar `RegistroAtivDia` (data, horaInicio, duração, refs pessoa/exercício) ao confirmar conclusão; marcar exercício como realizado na lista; tratar falha de rede.
- **DoD:** registro visível no console Firestore; UI reflete status realizado.

---

## Sprint 4 — Consistência de Perfil & Qualidade (02/10 → 16/10)

### T4.1 — Perfil com dados completos *(Concluída antecipadamente)*
- **US:** US06 · **Prioridade:** Média · **Status:** ✅ Concluída (PR #23 / Issue #13)
- **Escopo:** Perfil exibe altura, peso, data de nascimento, telefone e demais campos biométricos; formulário de edição com máscaras e validações; consistência visual e TTS.


### T4.2 — QA de regressão + atualização de documentação *(1 semana)*
- **Descrição:** reexecutar matriz completa (`qa-matriz-testes.md`) incluindo os novos fluxos (detalhe, execução, alertas, registro); atualizar `user-stories.md` e `README.md`; fechar issues resolvidas.
- **DoD:** matriz atualizada sem itens críticos abertos; release tag da iteração.

### T4.3 — Configuração de CI e SonarQube Quality Gate *(Issue #36)*
- **Tipo:** Infraestrutura / CI-CD · **Responsável:** Taciano Silva · **Status:** 🟡 Em andamento (Branch `feature/configurar-sonarqube-ci`)
- **Escopo:** Criação do `sonar-project.properties` com exclusões e relatório de cobertura LCOV; pipeline no GitHub Actions (`.github/workflows/ci.yml`) com scan unificado (Community Edition) e bloqueio por Quality Gate (`sonar.qualitygate.wait=true`); documentação em `docs/ci-sonarqube.md`.

---

## Sprint 5 — Refinamento Alfa, Acessibilidade & Gestão de Treino (31/10 → 15/11)

**Objetivo:** Integrar os ajustes prioritários do teste alfa de usabilidade com idosos, simplificar a autenticação e disponibilizar a gestão de exercícios para personal trainers.

### T5.1 — Rolagem contínua e controles do cronômetro na WorkoutScreen *(Issue #73 / PR #74)*
- **US:** US11 e US08 · **Prioridade:** Alta · **Revisor:** @Tome-arcanjo
- **Escopo:** Rolagem de tela cheia unificada (`SingleChildScrollView`), remoção de play vago em `00:00`, exibição do nome do exercício no relógio com link de retorno, legenda concisa nos cards e descrição completa no topo da tela de detalhes.

### T5.2 — Chip de intensidade na tela de detalhes *(Issue #53 / PR #68)*
- **US:** US08 e US21 · **Prioridade:** Alta · **Revisor:** @Icaro-Nonato
- **Escopo:** Exibir chip informativo de intensidade (Leve / Moderado / Intenso) em `ExerciseDetailScreen` com cores semânticas e narração acessível via TTS.

### T5.3 — Autenticação simplificada (Google Sign-In e E-mail) *(Issues #21, #67 / PRs #71, #72)*
- **US:** US01 e US02 · **Prioridade:** Alta · **Revisores:** @Tome-arcanjo, @Isaac-Ribeiro
- **Escopo:** Padronização do campo de login exclusivamente para E-mail e adição do botão de login em 1 clique com Conta Google para facilitar acesso por idosos.

### T5.4 — Cadastro e edição de exercícios por Personal Trainer *(Issues #65, #66 / PR #70)*
- **US:** Backlog Personal · **Prioridade:** Alta · **Revisor:** @LuizFelixDev
- **Escopo:** Telas de formulário e edição de novos exercícios no catálogo do Firestore com permissão RBAC restrita a personal/admin.

---

## Sprint 6 — Treinos ao Ar Livre, Histórico & Release Beta (16/11 → 30/11)

**Objetivo:** Expandir as modalidades de treino ao ar livre, implementar o acompanhamento da evolução do idoso e consolidar a release Beta do aplicativo.

### T6.1 — Treinos na Rua (Ao Ar Livre) *(Issue #57 / PR #69)*
- **US:** US16 · **Prioridade:** Média · **Revisor:** @LuizFelixDev
- **Escopo:** Rota dedicada e catálogo de exercícios orientados para praças e caminhada ao ar livre com geolocalização/recomendações.

### T6.2 — Tela de Progresso e Evolução do Idoso *(Issue #56)*
- **US:** US18 · **Prioridade:** Alta
- **Escopo:** Exibição do histórico de treinos concluídos consumindo `RegistroAtivDia` com métricas visuais acessíveis (dias ativos, tempo total acumulado e gráficos simplificados).

### T6.3 — Homologação da Release Beta e Auditoria Final de Acessibilidade
- **Escopo:** Verificação completa com leitores de tela (TalkBack / leitor web), bateria de testes de regressão em dispositivos reais e publicação da release tag `v0.2.0-beta`.

---

## Definition of Done (todas as tarefas)

1. Critérios de aceite das US relacionadas marcados e verificados em device Android.
2. `flutter analyze` sem erros/warnings novos.
3. Navegação testada nos dois sentidos (ida/volta).
4. Novas telas cobrem TTS ("Ler tela") e textos grandes legíveis.
5. Sem segredos/chaves hardcoded; configs sensíveis fora do git.
6. Documentação impactada atualizada (user-stories, matriz QA, README se aplicável).

## Dependências e riscos

| Item | Impacto | Mitigação |
|---|---|---|
| T1.3 (Firebase) bloqueia validações em device das sprints seguintes | Alto | Executar desde o dia 1 da S1; seed local de contorno enquanto isso |
| Parse de descrição p/ tempo previsto (T3.1) pode ser impreciso | Médio | Padronizar seed; campo estruturado previsto na US20 |
| Conta pessoal antiga com dados de teste ativos | Baixo | Desativar após validação do novo projeto |
| Acesso admin à conta Labican ainda não concedido a todos | Médio | Solicitar convites no início da S1 |

## Pós-S4 (próximo ciclo — sugestão)

- US16 Treinos na Rua · US17 Treinos Sugeridos · US18 Progresso (consome `RegistroAtivDia`) · US19 Notificações · US20 alinhamento ao modelo conceitual do backend (integração com a API Django quando disponível).
