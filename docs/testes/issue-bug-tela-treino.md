---
name: Relatório de Bug
about: Comportamento incorreto encontrado no app
title: "[Bug] Rolagem fragmentada no celular e botão de play indevido abaixo do cronômetro na WorkoutScreen"
labels: bug, acessibilidade, frontend
projects: []
assignees: []
---

**Type:** Bug  
**Tags:** `frontend`, `acessibilidade`, `workout`, `ux-idosos`  
**User Story:** US11 (Marcar exercício em execução) e US07 (Listar exercícios por categoria)  
**Refs:** #44, #52, PR #60, PR #50  

## 📝 Descrição

- **Contexto:** Tela de treino (`/workout`), especialmente quando acessada através de navegadores em smartphones ou telas de tamanho reduzido.
- **Comportamento atual:**
  1. O cabeçalho azul do cronômetro e os botões de seleção de categoria ("Coração" e "Músculo") estão fixos no topo da tela, ocupando mais de 50% da altura vertical do celular. Apenas a lista inferior de exercícios rola dentro de um `Expanded`, o que deixa uma área de toque e visualização minúscula (apenas meio card visível), dificultando a rolagem para idosos.
  2. Abaixo do cronômetro em `00:00` é exibido um botão de Play (`Icons.play_arrow`). No entanto, tocar nesse botão não surte efeito prático quando nenhum exercício foi selecionado, gerando confusão cognitiva de que o treino deveria iniciar por ali.
- **Comportamento esperado:**
  1. A tela inteira deve rolar de ponta a ponta (`SingleChildScrollView` / `CustomScrollView`), de modo que o cronômetro e categorias acompanhem a rolagem ao puxar para cima, liberando toda a tela do smartphone para a lista de exercícios.
  2. Abaixo do cronômetro devem existir apenas os botões de controle de sessão ativa: **Pausar** (`Icons.pause`) e **Parar** (`Icons.stop`). O botão de **Play** pertence aos cards individuais dos exercícios (onde o idoso escolhe qual exercício praticar).

## 📍 Localização

- `lib/screens/workout/workout_screen.dart`

## 🔧 Como Reproduzir

1. Abrir o app em resolução de smartphone (ex.: 360x800 ou 412x915).
2. Fazer login e navegar para "Treinos em Casa" (`/workout`).
3. Notar que o cabeçalho azul e as categorias consomem a maior parte da tela vertical, deixando o primeiro exercício cortado.
4. Tentar rolar a tela deslizando o dedo sobre o cronômetro ou categorias (a tela não se move).
5. Notar o botão de Play ao lado do Stop abaixo de `00:00` e tentar tocá-lo (nenhuma ação ocorre).

## 💻 Ambiente

- Dispositivo/emulador: Smartphone físico (Galaxy / Samsung Internet / Chrome Mobile)
- Plataforma: Web Mobile
- Versão do app: Alfa (v0.1.0)
- Feedback: Profa. Karliane B. de Oliveira (04/11/2026)

## 📎 Evidências

- Imagem: [`docs/testes/teste-alfa-tela-treino-rolagem-e-cronometro.jpeg`](teste-alfa-tela-treino-rolagem-e-cronometro.jpeg)
- Registro detalhado: [`docs/testes/registro-testes-alfa.md`](registro-testes-alfa.md)

## 🏁 Definição de Pronto (DoD)

- [ ] Causa raiz identificada e documentada.
- [ ] Rolagem da tela de treino unificada para o conteúdo inteiro.
- [ ] Remoção do botão de play abaixo do relógio, mantendo apenas Pause e Stop vinculados ao exercício ativo.
- [ ] Correção verificada no cenário de reprodução mobile.
- [ ] Testes de widget atualizados e cobrindo os novos comportamentos (`test/screens/workout_screen_test.dart` e `test/workout_screen_test.dart`).
- [ ] `flutter analyze` sem erros/avisos.
