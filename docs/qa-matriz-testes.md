# Matriz de Testes & QA — AtivaMente (App Flutter)

Documento de rastreabilidade de testes e matriz de garantia de qualidade do aplicativo AtivaMente.

---

## 1. Diagnóstico de Causas Raízes (Bugs Registrados)

### Bug Issue #8 — Nome do Usuário Logado (US05)
- **Sintoma:** O nome do usuário exibia "Usuário", "Nome do Usuário" ou string em branco no cabeçalho da Home e na tela de Perfil.
- **Causas Raízes Diagnosticadas:**
  1. **Documento Ausente em `Pessoas`:** Contas de usuário criadas por fluxos secundários ou legados não possuíam o documento `Pessoas/{uid}` criado no Cloud Firestore.
  2. **Fallback Ineficiente para String Vazia:** O código anterior fazia `pessoa?.nome ?? 'Usuário'`, porém se `nome` no Firestore fosse uma string vazia (`''`), o operador `??` não era acionado, mantendo a string vazia na tela.
  3. **Ausência de Integração com Firebase Auth:** O provider não consultava `user.displayName` ou `user.email` como fonte secundária de identidade ao aguardar ou quando o Firestore estivesse sem dados.
  4. **Sem Auto-criação On-demand:** Contas sem documento `Pessoas` no Firestore não tinham um mecanismo de auto-recuperação/migração on-demand ao realizar login.

- **Solução Aplicada:**
  - Criação da função pura `getEffectiveDisplayName(pessoa, user)` com a hierarquia de precedência:
    1. `Pessoa.nome` (se preenchido e não-vazio);
    2. `User.displayName` do Firebase Auth (se preenchido e não-vazio);
    3. Prefixo do e-mail do Firebase Auth (parte anterior ao `@`);
    4. Fallback genérico `'Usuário'`.
  - Introdução do `userDisplayNameProvider` para servir o nome de forma síncrona e resiliente ao estado do Auth/Firestore.
  - Atualização do `userDataProvider` para realizar a auto-criação on-demand do documento `Pessoas/{uid}` com `SetOptions(merge: true)`.

### Feature Issue #37 — Conclusão do Modo Alto Contraste & Separação de Cards (US15)
- **Sintomas:**
  1. **Cards Pretos em Fundo Preto:** Em Material 3, o papel `surfaceContainerLow` não era definido no `highContrastTheme`, fazendo a cor do Card cair em `surface` (preto), igual ao fundo da tela (`scaffoldBackgroundColor`), perdendo a separação visual.
  2. **Cores Hardcoded:** Telas com cores fixas (`Colors.white`, `Colors.grey`, etc.) ignoravam o tema ativo, gerando pares com baixo contraste no modo alto contraste.
- **Solução Aplicada:**
  - Definição explícita de `surfaceContainerLow` (`0xFF1C1C1C`), `surfaceContainer` (`0xFF262626`) e `surfaceContainerHighest` (`0xFF333333`) no `highContrastTheme`.
  - Configuração de `cardTheme` com borda visível de alto contraste (`0xFFFFE600`, 2px) e `inputDecorationTheme` para campos de formulário.
  - Substituição de cores fixas por tokens do `colorScheme` em `welcome_screen.dart`, `login_screen.dart`, `register_screen.dart`, `add_user_screen.dart`, `edit_profile_screen.dart` e `profile_screen.dart`.

### Bug Issue #46 — Drift no Cronômetro de Exercício
- **Sintoma:** O cronômetro podia apresentar descompasso/drift com o tempo real decorrido em execuções prolongadas ou segundo plano devido à acumulação de atrasos de agendamento do `Timer.periodic`.
- **Solução Aplicada:** Cálculo do tempo decorrido utilizando timestamps de `DateTime` no provider de treino (`elapsed = DateTime.now().difference(inicio)`).

### Bug Teste Alfa — Rolagem e Controles da Tela de Treino (US11, US07)
- **Sintomas (Feedback Profa. Karliane em 04/11/2026):**
  1. **Rolagem travada no celular:** O cronômetro e as categorias ocupam espaço fixo exagerado no topo da tela, reduzindo a área de visualização e rolagem da lista de exercícios a menos da metade da tela em smartphones. Idosos encontram dificuldade para navegar e visualizar os exercícios disponíveis.
  2. **Botão de Play abaixo do relógio incoerente:** O botão de Play abaixo do cronômetro quando nenhum exercício foi iniciado (`00:00`) induz o usuário a acreditar que o treino inicia ali, mas o toque não tem efeito, já que o disparo da execução ocorre no card do exercício.
- **Evidência:** [`docs/testes/teste-alfa-tela-treino-rolagem-e-cronometro.jpeg`](testes/teste-alfa-tela-treino-rolagem-e-cronometro.jpeg) e registro em [`docs/testes/registro-testes-alfa.md`](testes/registro-testes-alfa.md).
- **Causas Raízes Diagnosticadas:**
  1. Uso de `Column` com cabeçalho estático e `Expanded(child: ListView.builder(...))` em `WorkoutScreen`, limitando o viewport de rolagem.
  2. Presença de alternância para `Icons.play_arrow` no bloco do relógio em vez de restringir os controles aos botões de sessão (`Icons.pause` e `Icons.stop`).
- **Solução Proposta:**
  1. Tornar a tela de treino inteiramente rolável (`SingleChildScrollView` ou `CustomScrollView`).
  2. Substituir o botão de play abaixo do relógio por controles dedicados de sessão: Pausar e Parar, deixando o início/play exclusivamente nos cards de exercícios.

---

## 2. Matriz de Casos de Teste (QA)

| ID Caso de Teste | US | Funcionalidade / Cenário | Pré-condição | Passos de Execução | Resultado Esperado | Status |
|---|---|---|---|---|---|---|
| **CT-US05-01** | US05 | Exibição de nome real completo | Usuário cadastrado com nome "Maria Silva" em `Pessoas` | 1. Fazer login com a conta.<br>2. Navegar para a Home.<br>3. Navegar para a tela de Perfil. | "Maria Silva" é exibido no cabeçalho da Home e na tela de Perfil. | ✅ Aprovado |
| **CT-US05-02** | US05 | Fallback para `user.displayName` | Conta no Firebase Auth com `displayName = "João Auth"`, sem doc `Pessoas` | 1. Logar com a conta.<br>2. Abrir Home e Perfil. | "João Auth" é exibido enquanto o doc é auto-criado no Firestore. | ✅ Aprovado |
| **CT-US05-03** | US05 | Fallback para e-mail | Conta criada via Auth com e-mail `carlos.dev@ativamente.org`, sem nome | 1. Logar com a conta.<br>2. Abrir Home e Perfil. | "carlos.dev" é exibido no cabeçalho e perfil. | ✅ Aprovado |
| **CT-US05-04** | US05 | Auto-criação de doc `Pessoas` | Conta sem documento na coleção `Pessoas` do Firestore | 1. Efetuar login.<br>2. Verificar coleção `Pessoas` no Firestore. | O documento `Pessoas/{uid}` é auto-criado com os dados básicos do Auth. | ✅ Aprovado |
| **CT-US05-05** | US05 | Ausência de travamentos em loading | Troca rápida de telas no carregamento inicial | 1. Efetuar login.<br>2. Alternar entre Home e Perfil imediatamente. | Nome do Auth/Fallback aparece de imediato sem travar UI ou mostrar erro bruto. | ✅ Aprovado |
| **CT-US06-01** | US06 | Máscara e validação de data de nascimento | Tela de edição de perfil aberta | 1. Digitar data inválida (ex.: 31/02/2020 ou data futura).<br>2. Salvar. | Formulário bloqueia submissão e orienta com mensagem clara. | ✅ Aprovado |
| **CT-US06-02** | US06 | Limites biológicos de peso e altura | Tela de edição de perfil aberta | 1. Inserir peso de 70.5kg e altura 1.72m com vírgula ou ponto.<br>2. Salvar. | Dados são normalizados e salvos com sucesso no Firestore. | ✅ Aprovado |
| **CT-US08-01** | US08 | Abertura da tela de detalhe | Lista de exercícios carregada | 1. Tocar em um card de exercício.<br>2. Visualizar tela `/exercise/:id`. | Nome, descrição, categoria, tipo, nível de intensidade e placeholder de mídia são renderizados. | ✅ Aprovado |
| **CT-US08-02** | US08 | Retorno preservando filtros | Tela de detalhe aberta a partir da aba Músculo | 1. Tocar no botão voltar da AppBar. | Retorna à tela de treino mantendo a aba Músculo selecionada. | ✅ Aprovado |
| **CT-US10-01** | US10 | Voltar da tela de treino | Tela de treino `/workout` aberta | 1. Tocar no botão voltar na AppBar. | Retorna à Home via `context.go('/home')` preservando estado de autenticação. | ✅ Aprovado |
| **CT-US11-01** | US11 | Marcação de exercício ativo | Tela de treino ou detalhe aberta | 1. Clicar no botão de iniciar exercício. | Exercício fica visualmente marcado como ativo e o cronômetro inicia automaticamente. | ✅ Aprovado |
| **CT-US11-02** | US11 | Troca e interrupção de exercício | Exercício A em andamento | 1. Iniciar exercício B. | Exercício A é desmarcado, exercício B torna-se o ativo e cronômetro é reiniciado. | ✅ Aprovado |
| **CT-US11-03** | US11 | Rolagem completa da tela de treino no celular | Tela de treino `/workout` aberta em smartphone | 1. Tocar em qualquer ponto da tela (inclusive cronômetro ou categorias) e deslizar para cima.<br>2. Observar a visualização da lista de exercícios. | A tela rola completamente de forma unificada; os exercícios ocupam a tela inteira com excelente legibilidade e sem cortes de layout. | ⏳ Pendente de Correção |
| **CT-US11-04** | US11 | Controles abaixo do cronômetro sem botão de play | Tela de treino aberta sem exercício ativo | 1. Observar botões abaixo do tempo `00:00`.<br>2. Iniciar exercício no card.<br>3. Observar botões do cronômetro. | Inicialmente exibe botões Pause e Stop desabilitados (sem botão Play). Durante a execução, o botão Pause permite pausar e Stop encerra a sessão. | ⏳ Pendente de Correção |
| **CT-US15-01** | US15 | Separação visual de Cards | Modo Alto Contraste ativado | 1. Ativar Modo Alto Contraste no Perfil.<br>2. Navegar por Home e listas de treinos. | Cards exibem fundo escuro destacado (`0xFF1C1C1C`) e borda contrastante (`0xFFFFE600`, 2px). | ✅ Aprovado |
| **CT-US15-02** | US15 | Formulários em Alto Contraste | Modo Alto Contraste ativado | 1. Abrir telas de Login, Registro, Editar Perfil e Adicionar Usuário. | Textos, rótulos e bordas com taxa de contraste WCAG AA >= 4.5:1, sem textos ilegíveis. | ✅ Aprovado |
| **CT-US09-01** | US09 | Povoamento oficial do catálogo (Manual do Idoso) | Acesso administrativo no projeto `ativamente-labican-ufrn` | 1. Executar seed idempotente do catálogo inicial.<br>2. Consultar coleção `Exercicios` no Cloud Firestore. | 12 exercícios oficiais do Manual semeados com intensidade e idempotência garantida (`docs/catalogo-exercicios-manual.md`). | ✅ Aprovado |
| **CT-US21-01** | US21 | Chips e filtro por intensidade | Lista de treino carregada | 1. Tocar no chip de intensidade (ex.: Leve). | Lista filtra exercícios pela intensidade selecionada e TTS narra o filtro ativo. | ✅ Aprovado |

---

## 3. Matriz de Regressão da Iteração (Sprints 1 a 4)

| Módulo / Funcionalidade | Status | Evidência / Implementação |
|---|---|---|
| Autenticação (Login, Cadastro, Logout) | ✅ Aprovado | `lib/screens/auth/` com Firebase Auth e validações acessíveis |
| Guarda de Rotas Privadas | ✅ Aprovado | `lib/routes.dart` com redirecionamento de não autenticados |
| Identificação do Usuário (US05) | ✅ Aprovado | `userDisplayNameProvider` + `getEffectiveDisplayName` (PR #40) |
| Perfil e Dados Biométricos (US06) | ✅ Aprovado | `EditProfileScreen` com máscaras e validações (PR #23) |
| Seed Oficial do Catálogo (US09) | ✅ Aprovado | 12 exercícios oficiais semeados com idempotência no Firestore (PR #63) |
| Catálogo de Exercícios e Categorias (US07) | ✅ Aprovado | Filtragem em abas Coração/Músculo via `exerciciosFiltradosProvider` |
| Detalhe do Exercício (US08) | ✅ Aprovado | Rota `/exercise/:id` e `ExerciseDetailScreen` (PR #30, PR #60) |
| Navegação Voltar do Treino (US10) | ✅ Aprovado | `context.go('/home')` evitando travamento de pilha (PR #6) |
| Marcação de Exercício e Cronômetro (US11) | ✅ Aprovado | `exercicioEmExecucaoProvider` + cálculo por `DateTime` (PR #47, PR #60) |
| Acessibilidade de Toque (Issue #44) | ✅ Aprovado | Área de toque ampliada nos botões da lista (PR #50) |
| Leitura de Tela TTS (US14) | ✅ Aprovado | Botão de volume em todas as telas com `flutter_tts` pt-BR |
| Modo Alto Contraste (US15) | ✅ Aprovado | Suporte WCAG AAA no tema escuro de alto contraste (PR #42) |
| Intensidade dos Exercícios (US21) | ✅ Aprovado | Modelo com intensidade (1 a 10) e chips de filtro (PR #32) |
| Pipeline e Análise Estática (Issue #36) | ✅ Aprovado | GitHub Actions com SonarQube Quality Gate ativo (PR #58) |
| Regras do Firestore e Deploy (Issue #7) | ✅ Aprovado | `firestore.rules` com RBAC e política de release na main (PR #63) |
