import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercicio.dart';
import '../../providers/active_exercise_provider.dart';
import '../../providers/tts_provider.dart';
import '../../providers/firestore_provider.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(exerciciosProvider).when(
      data: (exercicios) {
        for (final exercicio in exercicios) {
          if (exercicio.id == exerciseId) {
            return _ExerciseDetailBody(exercicio: exercicio);
          }
        }
        return const _StateScreen(
          title: 'Exercício',
          message: 'Exercício não encontrado.',
          screenText: 'Detalhe do exercício. Exercício não encontrado.',
        );
      },
      loading: () => const _StateScreen(
        title: 'Exercício',
        message: 'Carregando exercício...',
        screenText: 'Detalhe do exercício. Carregando.',
        showProgress: true,
      ),
      error: (err, stack) {
        debugPrint('Erro ao buscar exercício $exerciseId: $err');
        return _StateScreen(
          title: 'Exercício',
          message: 'Não foi possível carregar o exercício. Tente novamente.',
          screenText: 'Detalhe do exercício. Erro ao carregar. Tente novamente.',
        );
      },
    );
  }
}

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/workout');
  }
}

class _StateScreen extends ConsumerWidget {
  const _StateScreen({
    required this.title,
    required this.message,
    required this.screenText,
    this.showProgress = false,
  });

  final String title;
  final String message;
  final String screenText;
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readScreen = ref.watch(readScreenProvider(screenText));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _goBack(context),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: Center(
        child: showProgress
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
      ),
    );
  }
}

String _formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

class _ExerciseDetailBody extends ConsumerWidget {
  const _ExerciseDetailBody({required this.exercicio});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeExerciseProvider);
    final isThisActive = activeState.exerciseId == exercicio.id;
    final isRunning = isThisActive && activeState.isRunning;
    final isPaused = isThisActive && !activeState.isRunning;
    final elapsedSeconds = isThisActive ? activeState.elapsedSeconds : 0;

    final statusLabel = isRunning
        ? 'Em execução'
        : isPaused
        ? 'Pausado'
        : 'Parado';
    final formattedTime = _formatTime(elapsedSeconds);

    final screenText =
        'Detalhe do exercício. ${exercicio.nome}. Status: $statusLabel. '
        'Tempo decorrido: $formattedTime. '
        'Categoria: ${exercicio.categoria.nome}. '
        'Tipo: ${exercicio.tipo.nome}. Descrição: ${exercicio.descricao}';
    final readScreen = ref.watch(readScreenProvider(screenText));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _goBack(context),
        ),
        title: const Text('Voltar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercicio.nome,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoChip(icon: Icons.category, label: exercicio.categoria.nome),
                _InfoChip(icon: Icons.fitness_center, label: exercicio.tipo.nome),
              ],
            ),
            const SizedBox(height: 24),
            _ExecutionControlCard(
              exerciseId: exercicio.id,
              isThisActive: isThisActive,
              isRunning: isRunning,
              statusLabel: statusLabel,
              formattedTime: formattedTime,
            ),
            const SizedBox(height: 24),
            const _MediaPlaceholder(),
            const SizedBox(height: 24),
            Text(
              'Descrição',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exercicio.descricao.isNotEmpty
                  ? exercicio.descricao
                  : 'Sem descrição disponível.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExecutionControlCard extends ConsumerWidget {
  const _ExecutionControlCard({
    required this.exerciseId,
    required this.isThisActive,
    required this.isRunning,
    required this.statusLabel,
    required this.formattedTime,
  });

  final String exerciseId;
  final bool isThisActive;
  final bool isRunning;
  final String statusLabel;
  final String formattedTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.read(activeExerciseProvider.notifier);

    return Card(
      margin: EdgeInsets.zero,
      elevation: isThisActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isThisActive
              ? colorScheme.primary
              : colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isThisActive ? Icons.timer : Icons.timer_outlined,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              label: 'Tempo decorrido: $formattedTime',
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                Semantics(
                  button: true,
                  enabled: !isRunning,
                  label: 'Iniciar exercício',
                  child: Tooltip(
                    message: 'Iniciar exercício',
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 52),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor:
                            colorScheme.surfaceContainerHighest,
                        disabledForegroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                      onPressed: isRunning
                          ? null
                          : () => notifier.startExercise(exerciseId),
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        'Iniciar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  enabled: isRunning,
                  label: 'Pausar exercício',
                  child: Tooltip(
                    message: 'Pausar exercício',
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(120, 52),
                        foregroundColor: colorScheme.primary,
                        disabledForegroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        side: BorderSide(
                          color: isRunning
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      onPressed: isRunning
                          ? () => notifier.pauseExercise()
                          : null,
                      icon: const Icon(Icons.pause, size: 28),
                      label: const Text(
                        'Pausar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  enabled: isThisActive,
                  label: 'Parar exercício',
                  child: Tooltip(
                    message: 'Parar exercício',
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(120, 52),
                        foregroundColor: colorScheme.error,
                        disabledForegroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        side: BorderSide(
                          color: isThisActive
                              ? colorScheme.error
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      onPressed: isThisActive
                          ? () => notifier.stopExercise()
                          : null,
                      icon: const Icon(Icons.stop, size: 28),
                      label: const Text(
                        'Parar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 56, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'Vídeo em breve',
              style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, color: colorScheme.primary, size: 20),
      label: Text(
        label.isNotEmpty ? label : '—',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
    );
  }
}
