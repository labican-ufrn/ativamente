import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/intensity.dart';
import '../../models/exercicio.dart';
import '../../providers/tts_provider.dart';
import '../../providers/firestore_provider.dart';
import '../../providers/active_exercise_provider.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  String _selectedCategory = 'Coracao'; // Coracao or Musculo

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _resumoDescricao(String descricao) {
    if (descricao.isEmpty) return '';
    final pontoIndex = descricao.indexOf('.');
    if (pontoIndex != -1) {
      return descricao.substring(0, pontoIndex + 1).trim();
    }
    return descricao.trim();
  }

  void _filterByIntensity(int? intensidade) {
    ref.read(intensidadeFilterProvider.notifier).setIntensidade(intensidade);
  }

  Widget _buildExerciseTile(
    Exercicio exercicio,
    ActiveExerciseState activeState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = activeState.exerciseId == exercicio.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: isActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        titleAlignment: ListTileTitleAlignment.center,
        title: Row(
          children: [
            Expanded(
              child: Text(
                exercicio.nome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isActive) Icon(Icons.timer, color: colorScheme.primary),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _resumoDescricao(exercicio.descricao),
              style: const TextStyle(fontSize: 16),
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              Text(
                activeState.isRunning ? 'Em execução' : 'Pausado',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            intensityChip(
              intensidade: exercicio.intensidade,
              onPressed: () => _filterByIntensity(exercicio.intensidade),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isActive && activeState.isRunning
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
              ),
              color: colorScheme.primary,
              iconSize: 36,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              tooltip: isActive && activeState.isRunning
                  ? 'Pausar exercício'
                  : 'Iniciar exercício',
              onPressed: () => ref
                  .read(activeExerciseProvider.notifier)
                  .toggleExercise(exercicio.id),
            ),
          ],
        ),
        onTap: () => context.push('/exercise/${exercicio.id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeExerciseProvider);
    final selectedIntensity = ref.watch(intensidadeFilterProvider);
    final hasIntensityFilter = selectedIntensity != null;

    final exerciciosAsync = ref.watch(exerciciosProvider);
    final activeExercise = exerciciosAsync.asData?.value
        .where((e) => e.id == activeState.exerciseId)
        .firstOrNull;

    final screenText = hasIntensityFilter
        ? 'Tela de Treino. Tempo decorrido. Categorias Coração e Músculo. Filtrado por intensidade ${rotuloIntensidade(selectedIntensity)}. Lista de exercícios.'
        : 'Tela de Treino. Tempo decorrido. Categorias Coração e Músculo. Exercícios com níveis Leve, Moderado e Intenso. Lista de exercícios.';
    final readScreen = ref.watch(readScreenProvider(screenText));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Voltar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (hasIntensityFilter)
            IconButton(
              icon: const Icon(Icons.filter_alt_off, size: 28),
              onPressed: () => _filterByIntensity(null),
              tooltip: 'Remover filtro de intensidade',
            ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  if (activeState.exerciseId != null) ...[
                    InkWell(
                      onTap: () =>
                          context.push('/exercise/${activeState.exerciseId}'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                activeExercise?.nome ??
                                    'Exercício em andamento',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Text(
                      'Selecione um exercício abaixo para iniciar',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    _formatTime(activeState.elapsedSeconds),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (activeState.exerciseId != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: activeState.isRunning
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            activeState.isRunning
                                ? Icons.play_arrow
                                : Icons.pause,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              activeState.isRunning ? 'EM EXECUÇÃO' : 'PAUSADO',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        button: true,
                        enabled: activeState.exerciseId != null,
                        label: activeState.isRunning
                            ? 'Pausar exercício'
                            : 'Retomar exercício',
                        child: Tooltip(
                          message: activeState.exerciseId == null
                              ? 'Exercício parado'
                              : activeState.isRunning
                              ? 'Pausar exercício'
                              : 'Retomar exercício',
                          child: InkWell(
                            onTap: activeState.exerciseId == null
                                ? null
                                : () {
                                    if (activeState.isRunning) {
                                      ref
                                          .read(activeExerciseProvider.notifier)
                                          .pauseExercise();
                                    } else {
                                      ref
                                          .read(activeExerciseProvider.notifier)
                                          .startExercise(
                                            activeState.exerciseId!,
                                          );
                                    }
                                  },
                            borderRadius: BorderRadius.circular(30),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: activeState.exerciseId != null
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.4),
                              child: Icon(
                                activeState.exerciseId != null &&
                                        !activeState.isRunning
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Semantics(
                        button: true,
                        enabled: activeState.exerciseId != null,
                        label: 'Parar exercício',
                        child: Tooltip(
                          message: activeState.exerciseId != null
                              ? 'Parar exercício'
                              : 'Nenhum exercício em andamento',
                          child: InkWell(
                            onTap: activeState.exerciseId != null
                                ? () => ref
                                    .read(activeExerciseProvider.notifier)
                                    .stopExercise()
                                : null,
                            borderRadius: BorderRadius.circular(30),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: activeState.exerciseId != null
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.4),
                              child: Icon(
                                Icons.stop,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryTab(Icons.favorite, 'Coracao'),
                  _buildCategoryTab(Icons.fitness_center, 'Musculo'),
                ],
              ),
            ),
            if (hasIntensityFilter)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Text(
                      'Filtrado por: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    intensityChip(
                      intensidade: selectedIntensity,
                      onPressed: () => _filterByIntensity(null),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _filterByIntensity(null),
                      child: const Text('Limpar filtro'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCategory == 'Coracao' ? 'Coração' : 'Músculo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ref
                      .watch(exerciciosFiltradosProvider(selectedIntensity))
                      .when(
                        data: (exercicios) {
                          final filteredExercicios = exercicios
                              .where(
                                (e) =>
                                    e.categoria.nome.toLowerCase() ==
                                    _selectedCategory.toLowerCase(),
                              )
                              .toList();

                          if (filteredExercicios.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: Text(
                                  'Nenhum exercício encontrado.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredExercicios.length,
                            itemBuilder: (context, index) {
                              return _buildExerciseTile(
                                filteredExercicios[index],
                                activeState,
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        error: (err, stack) {
                          debugPrint(
                            'Erro ao carregar exercícios filtrados: $err',
                          );
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Não foi possível carregar os exercícios no momento. Por favor, tente novamente mais tarde.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 2) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Progresso'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(IconData icon, String category) {
    final bool isSelected = _selectedCategory == category;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: colorScheme.primary,
          child: Icon(
            icon,
            color: colorScheme.onPrimary,
            size: 30,
          ),
        ),
      ),
    );
  }
}
