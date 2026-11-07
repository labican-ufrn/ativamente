# Cronômetro de exercício — comportamento

Referências: Issue [#45](https://github.com/labican-ufrn/ativamente/issues/45) (origem: revisão do PR #33 / Issue #10), Issue #46 (drift), US11 e US12 em [`user-stories.md`](user-stories.md).

Arquivos: [`lib/providers/active_exercise_provider.dart`](../lib/providers/active_exercise_provider.dart), [`lib/screens/workout/workout_screen.dart`](../lib/screens/workout/workout_screen.dart), [`lib/screens/workout/exercise_detail_screen.dart`](../lib/screens/workout/exercise_detail_screen.dart).

## Ao sair da tela: o cronômetro continua contando

**Decisão:** sair da Tela de Treino (seta "Voltar", aba Início/Perfil) **não pausa nem para** o exercício em execução. O tempo continua sendo contado até o usuário tocar em **Pausar** ou **Parar**.

Motivos:

1. **É uma sessão única, compartilhada.** O `activeExerciseProvider` é global e sem `autoDispose` de propósito: o mesmo estado é exibido na lista (`WorkoutScreen`) e no detalhe (`ExerciseDetailScreen`). Com `autoDispose`, o estado seria perdido quando nenhuma tela o observasse.
2. **O tempo é calculado pelo relógio, não por ticks** (correção da Issue #46). O `Timer.periodic` só atualiza a interface; o valor vem de `DateTime.now() - início + acumulado`. Por isso o tempo fica correto mesmo com a tela fechada ou o app em segundo plano.
3. **Sair sem querer não pode zerar o exercício.** Para o público idoso, um toque acidental em "Voltar" não deve apagar o tempo já realizado.
4. **Base para a US12** ("Cronômetro continua exibindo o tempo decorrido total") e para o futuro registro de conclusão (US13).

Ao voltar para a Tela de Treino, o cronômetro mostra o tempo total decorrido e o exercício continua marcado como "Em execução".

> **Limitação conhecida:** fora da Tela de Treino e do detalhe ainda não há indicador de exercício em andamento (ex.: banner na Home ou notificação do sistema). Se esse indicador for necessário, abrir uma issue própria — o estado global atual já permite implementá-lo.

## Reconstrução por segundo: só o texto do cronômetro

O estado muda a cada segundo (`elapsedSeconds`). Antes, a `WorkoutScreen` observava o estado inteiro no `build`, e **a tela toda — inclusive a lista de exercícios — era reconstruída a cada tick**.

Agora:

- A `WorkoutScreen` observa apenas `(exerciseId, isRunning)` via `activeExerciseProvider.select(...)`. Esses campos mudam só ao iniciar, pausar, parar ou trocar de exercício.
- O texto `MM:SS` foi extraído para o widget `_CronometroTexto`, o único que observa `elapsedSeconds`. O tick reconstrói só esse texto.
- A `ExerciseDetailScreen` já seguia esse padrão: o `watch` da execução fica no `_ExecutionControlCard` (Issue #52).

Teste de regressão: [`test/screens/workout_screen_timer_test.dart`](../test/screens/workout_screen_timer_test.dart) verifica que os itens da lista são as mesmas instâncias após vários ticks e que o tempo segue contando com a tela desmontada.
