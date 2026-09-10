import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercicio.dart';
import '../../providers/tts_provider.dart';
import '../../providers/firestore_provider.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId, this.exercicio});

  final String exerciseId;
  final Exercicio? exercicio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exercicio != null) {
      return _ExerciseDetailBody(exercicio: exercicio!);
    }

    return ref.watch(exerciciosProvider).when(
      data: (exercicios) {
        final found = exercicios.where((e) => e.id == exerciseId).toList();
        if (found.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => context.pop(),
              ),
              title: const Text('Exercício'),
            ),
            body: const Center(child: Text('Exercício não encontrado.')),
          );
        }
        return _ExerciseDetailBody(exercicio: found.first);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
          title: const Text('Exercício'),
        ),
        body: Center(child: Text('Erro: $err')),
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
          onPressed: () => context.pop(),
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 56, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'Vídeo em breve',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
    return Chip(
      avatar: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      label: Text(
        label.isNotEmpty ? label : '—',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
    );
  }
}
