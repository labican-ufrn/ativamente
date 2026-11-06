# Registro de Testes Alfa — AtivaMente

Este documento consolida os testes manuais e feedbacks recebidos após o deploy da versão para testes alfa do aplicativo AtivaMente (Labican/UFRN).

---

## 📅 Sessão de Testes 1 — 04/11/2026

- **Ambiente de Teste:** Navegador Web Mobile em dispositivo celular (Android / Samsung Internet, resolução móvel vertical).
- **URL acessada:** `https://tivamente-labican-ufrn.web.app/workout`
- **Responsável pelo teste:** Profa. Karliane B. de Oliveira.
- **Evidência visual:** [`teste-alfa-tela-treino-rolagem-e-cronometro.jpeg`](teste-alfa-tela-treino-rolagem-e-cronometro.jpeg)

---

### 📝 Comentários e Feedbacks Recebidos

1. **Sobre a tela de treino (rolagem e botões):**
   > *"Acessei pelo celular e essa rolagem p o idoso fica complicado. O ideal é q role a tela completa, sem deixar fixo o cronometro e os ícones abaixo dele. Outra coisa, se o play é no exercício, então não faz sentido ter o play abaixo do relógio, apenas pause e stop"*
   - **Evidência visual:** [`teste-alfa-tela-treino-rolagem-e-cronometro.jpeg`](teste-alfa-tela-treino-rolagem-e-cronometro.jpeg)

2. **Sobre os chips da tela de detalhe do exercício (redundância conceitual):**
   > *"Serve p que? Coração e cardio é a mesma coisa, né não?"*
   - **Evidência visual:** [`teste-alfa-detalhes-chips-categoria-tipo.jpeg`](teste-alfa-detalhes-chips-categoria-tipo.jpeg)

3. **Sobre a inteligibilidade da voz do TTS:**
   > *"Acho q a voz será difícil p um idoso entender, apesar de falar muuuito devagar, a fala é enrolada"*

---

### 🔍 Diagnóstico e Análise Técnica

#### 1. Rolagem fragmentada da tela de treino (Acessibilidade para Idosos)
- **Localização:** [`lib/screens/workout/workout_screen.dart`](../../lib/screens/workout/workout_screen.dart)
- **Comportamento Atual:**
  - A tela de treino foi estruturada com uma `Column` na qual o cabeçalho azul do cronômetro (`Container` com tempo `00:00` e controles) e as abas de categoria ("Coração" e "Músculo") ocupam posições fixas fora de qualquer área rolável.
  - Apenas a lista de exercícios (`ListView.builder`) possui rolagem, encapsulada em um `Expanded`.
- **Impacto no Celular:**
  - Em telas verticais de smartphones, o cabeçalho fixo consome mais de 50% a 60% da altura visível da tela.
  - A lista de exercícios fica estrangulada em uma pequena faixa inferior, onde mal é exibida a metade de um card (ex.: card "Agachamento na Cadeira" cortado na evidência).
  - Gestos de rolagem aplicados sobre o cronômetro ou categorias não surtem efeito, exigindo destreza motora fina do usuário idoso em uma área muito restrita.
- **Comportamento Esperado:**
  - A tela inteira deve rolar de forma unificada (`SingleChildScrollView` ou `CustomScrollView`).
  - Ao rolar para cima, o bloco do cronômetro e categorias se move junto com o restante da página, permitindo que a lista de exercícios se expanda pela altura completa do display do smartphone.

#### 2. Incoerência no botão de "Play" abaixo do cronômetro
- **Localização:** [`lib/screens/workout/workout_screen.dart`](../../lib/screens/workout/workout_screen.dart)
- **Comportamento Atual:**
  - Abaixo do cronômetro em `00:00`, exibe-se inicialmente um botão com o ícone de Play (`Icons.play_arrow`) ao lado do botão Stop (`Icons.stop`).
  - No entanto, tocar nesse botão Play quando nenhum exercício foi iniciado não tem efeito prático (`activeState.exerciseId == null`), pois o aplicativo exige que a seleção do exercício seja feita diretamente no card correspondente.
- **Impacto no Usuário:**
  - Causa confusão conceitual e induz o idoso ao erro, pois sugere que o treino como um todo pode ser iniciado naquele botão em destaque.
- **Comportamento Esperado:**
  - O início da atividade (Play) deve pertencer exclusivamente aos cards individuais de exercícios na lista (ou na tela de detalhes).
  - Abaixo do relógio devem existir apenas os botões de controle de sessão: **Pausar** (`Icons.pause`) e **Parar** (`Icons.stop`).
  - Quando nenhum exercício estiver em andamento, o botão Pausar permanece desabilitado/opaco.
  - Quando um exercício estiver em andamento, o idoso pode pausá-lo pelo cronômetro e encerrá-lo pelo botão Parar.

#### 3. Redundância e falta de contexto nos chips da tela de detalhe
- **Localização:** [`lib/screens/workout/exercise_detail_screen.dart`](../../lib/screens/workout/exercise_detail_screen.dart) e [`assets/data/exercises.json`](../../assets/data/exercises.json)
- **Comportamento Atual:**
  - O cabeçalho exibe chips crus como `[ Coracao ]` e `[ Cardio ]`, ou `[ Musculo ]` e `[ Forca ]`, sem rótulo ou significado claro.
  - No vocabulário popular e leigo, "Coração" e "Cardio" são sinônimos perfeitos; além disso, "Coracao" vem sem acento do JSON.
  - Falta o chip mais relevante para a dosagem do exercício: o **nível de intensidade** (Leve / Moderado / Intenso), que já é exibido na lista principal.
- **Impacto no Usuário:**
  - O idoso não entende para que servem dois chips redundantes lado a lado.
- **Comportamento Esperado:**
  - Tornar os chips informativos e claros (ex.: `Tipo: Aeróbico / Cardio` ou `Categoria: Coração`), corrigir ortografia (acentos) e adicionar o chip oficial de **Intensidade** (Leve, Moderado, Intenso) com cores semânticas.

#### 4. Voz do TTS com velocidade artificialmente lenta gerando fala "enrolada"
- **Localização:** [`lib/providers/tts_provider.dart`](../../lib/providers/tts_provider.dart)
- **Comportamento Atual:**
  - A velocidade de fala está fixada em `speechRate = 0.5`.
  - Em sintetizadores Web (Web Speech API) e Android, o valor `0.5` reduz drasticamente a cadência padrão pela metade, provocando distorção nos fonemas em português brasileiro (efeito robotizado, arrastado e "enrolado").
- **Impacto no Usuário:**
  - Dificuldade de compreensão auditiva por idosos, gerando o efeito oposto ao da acessibilidade.
- **Comportamento Esperado:**
  - Calibrar o padrão para um ritmo natural de fala em pt-BR (ex.: `0.8` a `1.0`), preservando a clareza e dicção natural das palavras.
  - Implementar a opção já desenhada na tela de Perfil (`Velocidade da Leitura (Voz)`) para permitir ao idoso personalizar entre velocidade Normal, Lenta e Confortável (US15).

---

### 🔗 Rastreabilidade

- **User Stories Impactadas:**
  - **US11 — Marcar exercício em execução:** Definição dos controles de tempo e papéis dos botões Play/Pause/Stop.
  - **US07 — Listar exercícios por categoria:** Layout e rolagem da tela de treino (`WorkoutScreen`).
  - **US08 — Ver detalhe do exercício:** Clareza semântica dos chips (categoria, tipo e intensidade calibrada).
  - **US14 — Ler tela em voz alta (TTS):** Inteligibilidade fonética e cadência natural da voz em pt-BR.
  - **US15 — Preferências de acessibilidade:** Ajuste funcional da velocidade da voz no Perfil.
- **Issues e PRs Relacionados:**
  - Refs: Issue #44 (Acessibilidade: área de toque na lista de treino)
  - Refs: Issue #52 / PR #60 (Controles de execução de exercício na tela de detalhe)
  - Refs: Issue #53 (Exibir chip de intensidade na ExerciseDetailScreen)
  - Refs: Issue #46 (Cálculo do cronômetro sem drift temporal)
