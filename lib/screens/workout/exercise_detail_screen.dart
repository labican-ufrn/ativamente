import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercicio.dart';
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

class _ExerciseDetailBody extends ConsumerWidget {
  const _ExerciseDetailBody({required this.exercicio});

  final Exercicio exercicio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenText =
        'Detalhe do exercício. ${exercicio.nome}. Categoria: ${exercicio.categoria.nome}. '
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
            const _MediaPlaceholder(),
            const SizedBox(height: 24),
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
