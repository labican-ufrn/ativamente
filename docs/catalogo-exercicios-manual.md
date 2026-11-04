# Catálogo de Exercícios — Manual do Idoso Ativo (EMCM / UFRN)

Este documento mapeia os exercícios do **Manual do Idoso Ativo** (produzido pela Escola Multicampi de Ciências Médicas — EMCM / UFRN Caicó) em relação ao catálogo do aplicativo **AtivaMente**, estabelecendo a matriz de rastreabilidade entre o material clínico/pedagógico oficial e os dados semeados e testados no app.

---

## 1. Visão Geral das Modalidades do Manual

O manual organiza a prescrição para a saúde física e mental do idoso em 5 modalidades essenciais:

1. **Treino Cardiovascular (Pág. 3):** Melhora o condicionamento cardiorrespiratório e controle metabólico (tempo contínuo de 15 a 30 minutos ou séries no degrau).
2. **Treino Osteoarticular (Págs. 4–6):** Mobilidade, flexibilidade e alívio de dores articulares (movimentos rítmicos de 30 a 60 segundos).
3. **Treino Muscular (Págs. 7–10):** Fortalecimento funcional para autonomia diária (8 a 15 repetições, 3 a 4 séries).
4. **Treino Pulmonar (Pág. 11):** Esforço respiratório diafragmático e expansão torácica (séries de 30 a 60 segundos).
5. **Treino Cognitivo / Relaxamento (Pág. 12):** Concentração, equilíbrio emocional e alívio de estresse com música e respiração consciente.

---

## 2. Matriz de Mapeamento: Manual vs. Catálogo do App

| Modalidade no Manual | Exercício Descrito no Manual | Código no App | Categoria / Tipo no App | Intensidade (1-10) | Status no App | Estratégia de Uso |
|---|---|---|---|:---:|:---:|---|
| **Cardiovascular** | Caminhada / Marcha contínua (15-30 min) | `coracao-cardio-01a` | Coração / Cardio | 3 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Cardiovascular** | Caminhada em esteira leve com apoio | `coracao-cardio-01b` | Coração / Cardio | 3 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Cardiovascular** | Subida e descida no batente/degrau | `coracao-cardio-02b` | Coração / Cardio | 5 (Moderado) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Cardiovascular** | Polichinelo adaptado sem impacto | `coracao-cardio-02a` | Coração / Cardio | 6 (Moderado) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Cardiovascular** | Caminhada na praça / ar livre | `narua-cardio-01a` | Coração / Cardio | 4 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Osteoarticular** | Alongamento de ombro e braços para cima | `flexibilidade-alongamento-01a` | Músculo / Alongamento | 2 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Osteoarticular** | Alongamento posterior sentado | `flexibilidade-alongamento-02a` | Músculo / Alongamento | 2 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Osteoarticular** | Extensão de joelho sentado (chute frontal) | `coracao-cardio-03a` | Coração / Cardio | 4 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Osteoarticular** | Alongamento de quadríceps em pé apoiado | `osteo-along-01a` | Músculo / Alongamento | 3 (Leve) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Osteoarticular** | Flexão de joelho em pé apoiado na cadeira | `osteo-mobil-01a` | Músculo / Mobilidade | 3 (Leve) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Osteoarticular** | Mobilidade da coluna em 4 apoios (gato) | `osteo-coluna-01a` | Músculo / Mobilidade | 2 (Leve) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Muscular** | Sentar e levantar da cadeira (braços cruzados) | `musculo-forca-01a` | Músculo / Força | 5 (Moderado) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Muscular** | Agachamento livre suave | `musculo-forca-01b` | Músculo / Força | 4 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Muscular** | Elevação de calcanhares (panturrilha apoiado) | `musculo-forca-03a` | Músculo / Força | 3 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Muscular** | Flexão de braço na parede | `musculo-forca-02a` | Músculo / Força | 4 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Muscular** | Postura do flamingo (equilíbrio unilateral) | `equilibrio-estabilidade-01a` | Músculo / Equilíbrio | 3 (Leve) | ✅ No Seed | Catálogo Inicial (Alfa) |
| **Muscular** | Abdução lateral de perna em pé apoiado | `musculo-perna-03a` | Músculo / Força | 4 (Leve) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Muscular** | Elevação pélvica deitado (ponte de glúteos) | `musculo-gluteo-01a` | Músculo / Força | 4 (Leve) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Muscular** | Elevação de perna estendida deitado | `musculo-perna-04a` | Músculo / Força | 5 (Moderado) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Muscular** | Abdominal curto deitado com joelhos flexos | `musculo-abdomen-01a` | Músculo / Core | 5 (Moderado) | ⏳ A Cadastrar | Roteiro de Teste do Personal |
| **Pulmonar** | Respiração profunda nasal-oral com braços | `pulmonar-resp-01a` | Pulmonar / Respiração | 2 (Leve) | ⏳ Nova Categoria | Roteiro de Teste do Personal |
| **Pulmonar** | Treino expiratório com bexiga / balão | `pulmonar-balao-01a` | Pulmonar / Respiração | 4 (Leve) | ⏳ Nova Categoria | Roteiro de Teste do Personal |
| **Cognitivo** | Relaxamento consciente com música calma | `cognitivo-relax-01a` | Mente / Relaxamento | 1 (Muito Leve) | ⏳ Nova Categoria | Roteiro de Teste do Personal |

---

## 3. Estratégia de Povoamento e Teste

### 3.1 O que Permanece no Seed Oficial Inicial (12 Exercícios)
O seed automático ([`assets/data/exercises.json`](../assets/data/exercises.json)) mantém os **12 exercícios fundamentais** das categorias **Coração** e **Músculo**. 

* **Objetivo:** Garantir que o aplicativo inicie com conteúdo clínico seguro e navegável para o idoso, sem sobrecarregar a tela com opções em excesso durante a fase alfa.

### 3.2 O que Fica para o Personal Trainer Cadastrar e Testar
Os exercícios marcados como **"⏳ A Cadastrar"** e **"⏳ Nova Categoria"** foram propositalmente reservados para a validação das novas telas de gestão do Personal Trainer:

1. **Teste da Issue #65 (`AddExerciseScreen`):**
   - O Personal Trainer usará exercícios reais do manual (ex.: *Subida no degrau*, *Abdução de perna*, *Elevação pélvica no chão*) como roteiro de homologação da tela de cadastro de novos exercícios.
2. **Teste da Issue #66 (`EditExerciseScreen`):**
   - O Personal Trainer poderá ajustar intensidades e instruções dos exercícios semeados, validando a edição em tempo real.
3. **Expansão de Categorias:**
   - A inclusão das modalidades **Pulmonar** e **Cognitivo/Mente** servirá de insumo para novas abas de filtragem na tela de Treino em sprints futuras.

---

## 4. Referência Bibliográfica
* **Título:** Manual do Idoso Ativo
* **Instituição:** Universidade Federal do Rio Grande do Norte (UFRN)
* **Unidade Acadêmica:** Escola Multicampi de Ciências Médicas do Rio Grande do Norte (EMCM) — Município de Caicó/RN.
* **Arquivo:** [`docs/Manual Ativo Idoso 2.pdf`](Manual%20Ativo%20Idoso%202.pdf)
