# Comunicação da Equipe — AtivaMente (Labican/UFRN)

Diretrizes e modelos para padronização da comunicação interna da equipe de desenvolvimento do projeto AtivaMente, especialmente via **WhatsApp** e canais rápidos.

---

## 📱 Regras de Formatação do WhatsApp

O WhatsApp não interpreta Markdown padrão do GitHub (como `**negrito**` ou `[link](url)`). Para garantir legibilidade imediata nos aplicativos móveis e web, siga estritamente a sintaxe nativa do WhatsApp:

| Estilo | Sintaxe WhatsApp | Exemplo |
|---|---|---|
| **Negrito** | `*texto*` | `*PR #74*` |
| *Itálico* | `_texto_` | `_dev_` |
| Tachado | `~texto~` | `~antigo~` |
| `Monoespaçado` | ````texto```` | ````SingleChildScrollView```` |
| **Links / URLs** | URLs cruas na própria linha | `🔗 https://github.com/...` *(nunca usar `[texto](url)`)* |

---

## 📌 Templates Padronizados

### 1. Mensagem para Revisor Individual (WhatsApp)

Usado pelo autor do PR para solicitar revisão a um membro específico da equipe.

```text
Fala, *{Nome do Revisor}*! Tudo bem? 👋

O *PR #{Número do PR}* ({Breve descrição}) está pronto para revisão na branch *dev*. 

📌 *Issue:* #{Número da Issue} — {Título da Issue}
🔗 https://github.com/labican-ufrn/ativamente/issues/{Número da Issue}

Pode dar uma conferida e aprovar o review lá, por favor?
👉 *Link do PR:* https://github.com/labican-ufrn/ativamente/pull/{Número do PR}

Valeu! 🚀
```

#### Exemplo real:
```text
Fala, *Tomé*! Tudo bem? 👋

O *PR #74* (unifica rolagem da tela de treino, melhora controles do cronômetro e detalhes) está pronto para revisão na branch *dev*. 

📌 *Issue:* #73 — [Bug] Rolagem fragmentada no celular e controles indevidos no cronômetro da WorkoutScreen
🔗 https://github.com/labican-ufrn/ativamente/issues/73

Pode dar uma conferida e aprovar o review lá, por favor?
👉 *Link do PR:* https://github.com/labican-ufrn/ativamente/pull/74

Valeu! 🚀
```

---

### 2. Mensagem Geral para Todos os Revisores da Milestone (WhatsApp)

Usado para avisar no grupo geral todos os revisores sobre os PRs abertos e com prazo para o milestone atual, de forma enxuta e direta em uma única mensagem.

```text
Fala, equipe! 👋 Lembrete de PRs abertos para a *{Nome da Milestone}*:

• *PR #{ID}* — {Título reduzido} (Issue #{IssueID}) ➔ Revisor: *@{Revisor}*
  👉 https://github.com/labican-ufrn/ativamente/pull/{ID}

Quem puder priorizar a revisão para fecharmos o prazo da sprint, agradeço! 🚀
```

#### Exemplo real:
```text
Fala, equipe! 👋 Lembrete de PRs abertos para a *Sprint 4 — Consistência & QA*:

• *PR #63* — SemVer, regras do Firestore e política de deploy (Issue #7) ➔ Revisor: *@Tome-arcanjo*
  👉 https://github.com/labican-ufrn/ativamente/pull/63

• *PR #72* — Padronização de login para e-mail (Issue #21) ➔ Revisor: *@Isaac-Ribeiro*
  👉 https://github.com/labican-ufrn/ativamente/pull/72

Quem puder priorizar a revisão para fecharmos o prazo da sprint, agradeço! 🚀
```

---

## 🤖 Como Acionar Agentes de IA para Gerar a Mensagem

Qualquer agente pode gerar a mensagem pronta automaticamente. Basta enviar no chat:

- *"Gere a mensagem de WhatsApp para o {Nome} revisar o PR #{Número}"*
- *"Gere a mensagem de revisão do último PR"*
- *"Notificar revisor do PR #{Número}"*

O agente consultará as informações do PR no GitHub (título, issue vinculada, reviewer e link) e formatará a mensagem pronta para colar no WhatsApp.

