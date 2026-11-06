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

### 2. Mensagem Geral para Grupo da Equipe (WhatsApp)

Usado para avisar no grupo geral quando um PR importante ou release estiver aberto ou integrado.

```text
Equipe, bom dia/tarde! 📢

Novo PR aberto apontando para *dev*:

🚀 *PR #{Número do PR}:* {Título do PR}
📌 *Issue:* #{Número da Issue}
👉 *Link:* https://github.com/labican-ufrn/ativamente/pull/{Número do PR}

Revisores solicitados: *@{Nome do Revisor}*
Quem puder dar uma força na validação, fique à vontade! 🙌
```

---

## 🤖 Como Acionar Agentes de IA para Gerar a Mensagem

Qualquer agente pode gerar a mensagem pronta automaticamente. Basta enviar no chat:

- *"Gere a mensagem de WhatsApp para o {Nome} revisar o PR #{Número}"*
- *"Gere a mensagem de revisão do último PR"*
- *"Notificar revisor do PR #{Número}"*

O agente consultará as informações do PR no GitHub (título, issue vinculada, reviewer e link) e formatará a mensagem pronta para colar no WhatsApp.

