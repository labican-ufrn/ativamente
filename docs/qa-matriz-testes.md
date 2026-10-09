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

---

## 2. Matriz de Casos de Teste (QA)

| ID Caso de Teste | US | Funcionalidade / Cenário | Pré-condição | Passos de Execução | Resultado Esperado | Status |
|---|---|---|---|---|---|---|
| **CT-US05-01** | US05 | Exibição de nome real completo | Usuário cadastrado com nome "Maria Silva" em `Pessoas` | 1. Fazer login com a conta.<br>2. Navegar para a Home.<br>3. Navegar para a tela de Perfil. | "Maria Silva" é exibido no cabeçalho da Home e na tela de Perfil. | ✅ Aprovado |
| **CT-US05-02** | US05 | Fallback para `user.displayName` | Conta no Firebase Auth com `displayName = "João Auth"`, sem doc `Pessoas` | 1. Logar com a conta.<br>2. Abrir Home e Perfil. | "João Auth" é exibido enquanto o doc é auto-criado no Firestore. | ✅ Aprovado |
| **CT-US05-03** | US05 | Fallback para e-mail | Conta criada via Auth com e-mail `carlos.dev@ativamente.org`, sem nome | 1. Logar com a conta.<br>2. Abrir Home e Perfil. | "carlos.dev" é exibido no cabeçalho e perfil. | ✅ Aprovado |
| **CT-US05-04** | US05 | Auto-criação de doc `Pessoas` | Conta sem documento na coleção `Pessoas` do Firestore | 1. Efetuar login.<br>2. Verificar coleção `Pessoas` no Firestore. | O documento `Pessoas/{uid}` é auto-criado com os dados básicos do Auth. | ✅ Aprovado |
| **CT-US05-05** | US05 | Ausência de travamentos em loading | Troca rápida de telas no carregamento inicial | 1. Efetuar login.<br>2. Alternar entre Home e Perfil imediatamente. | Nome do Auth/Fallback aparece de imediato sem travar UI ou mostrar erro bruto. | ✅ Aprovado |
| **CT-US15-01** | US15 | Separação visual de Cards | Modo Alto Contraste ativado | 1. Ativar Modo Alto Contraste no Perfil.<br>2. Navegar por Home e listas de treinos. | Cards exibem fundo escuro destacado (`0xFF1C1C1C`) e borda amarela contrastante (`0xFFFFE600`). | ✅ Aprovado |
| **CT-US15-02** | US15 | Formulários em Alto Contraste | Modo Alto Contraste ativado | 1. Abrir telas de Login, Registro, Editar Perfil e Adicionar Usuário. | Textos, rótulos e bordas com taxa de contraste WCAG AA >= 4.5:1, sem textos ilegíveis. | ✅ Aprovado |
