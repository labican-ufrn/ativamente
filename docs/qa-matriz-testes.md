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

---

## 2. Matriz de Casos de Teste (QA)

| ID Caso de Teste | US | Funcionalidade / Cenário | Pré-condição | Passos de Execução | Resultado Esperado | Status |
|---|---|---|---|---|---|---|
| **CT-US05-01** | US05 | Exibição de nome real completo | Usuário cadastrado com nome "Maria Silva" em `Pessoas` | 1. Fazer login com a conta.<br>2. Navegar para a Home.<br>3. Navegar para a tela de Perfil. | "Maria Silva" é exibido no cabeçalho da Home e na tela de Perfil. | ✅ Aprovado |
| **CT-US05-02** | US05 | Fallback para `user.displayName` | Conta no Firebase Auth com `displayName = "João Auth"`, sem doc `Pessoas` | 1. Logar com a conta.<br>2. Abrir Home e Perfil. | "João Auth" é exibido enquanto o doc é auto-criado no Firestore. | ✅ Aprovado |
| **CT-US05-03** | US05 | Fallback para e-mail | Conta criada via Auth com e-mail `carlos.dev@ativamente.org`, sem nome | 1. Logar com a conta.<br>2. Abrir Home e Perfil. | "carlos.dev" é exibido no cabeçalho e perfil. | ✅ Aprovado |
| **CT-US05-04** | US05 | Auto-criação de doc `Pessoas` | Conta sem documento na coleção `Pessoas` do Firestore | 1. Efetuar login.<br>2. Verificar coleção `Pessoas` no Firestore. | O documento `Pessoas/{uid}` é auto-criado com os dados básicos do Auth. | ✅ Aprovado |
| **CT-US05-05** | US05 | Ausência de travamentos em loading | Troca rápida de telas no carregamento inicial | 1. Efetuar login.<br>2. Alternar entre Home e Perfil imediatamente. | Nome do Auth/Fallback aparece de imediato sem travar UI ou mostrar erro bruto. | ✅ Aprovado |
