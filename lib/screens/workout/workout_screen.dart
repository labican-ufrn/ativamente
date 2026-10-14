Aqui está o código com todos os marcadores de conflito (`<<<<<<<`, `=======`, `>>>>>>>`) resolvidos, integrando os recursos das duas branches:

* **Da branch `dev`:** preservado o estado ativo do exercício (`activeExerciseProvider`, `activeState`), botões de play/pause/stop e destaque visual no card.
* **Da branch `feature/intensidade-exercicio`:** mantida a lógica do filtro por intensidade (`_filterByIntensity`, `intensidadeFilterProvider`, `exerciciosFiltradosProvider`), o chip de intensidade e a leitura acessível de tela atualizada.
* **Unificação do `_buildExerciseTile`:** o método agora recebe tanto o `Exercicio` quanto o `ActiveExerciseState`, exibindo o chip de intensidade ao lado do botão de reprodução/pausa.

```dart
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
            Text(exercicio.descricao, style: const TextStyle(fontSize: 16)),
            if (isActive) ...[
              const SizedBox(height: 8),
              Text(
                'Em execução',
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
              onPressed: () => ref
                  .read(activeExerciseProvider.notifier)
                  .toggleExercise(exercicio.id),
            ),
          ],
        ),
        onTap: () {
          // Navegação para a tela de detalhe entra quando o PR #30 (Issue #9) mergear.
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeExerciseProvider);
    final selectedIntensity = ref.watch(intensidadeFilterProvider);
    final hasIntensityFilter = selectedIntensity != null;

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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Text(
                  _formatTime(activeState.elapsedSeconds),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        final activeId = activeState.exerciseId;
                        if (activeId != null) {
                          ref
                              .read(activeExerciseProvider.notifier)
                              .toggleExercise(activeId);
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: activeState.exerciseId != null
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.4),
                        child: Icon(
                          activeState.isRunning
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: () {
                        ref
                            .read(activeExerciseProvider.notifier)
                            .stopExercise();
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: activeState.exerciseId != null
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.4),
                        child: Icon(
                          Icons.stop,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
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
          Expanded(
            child: Container(
              width: double.infinity,
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
                  Expanded(
                    child: ref
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
                              return const Center(
                                child: Text('Nenhum exercício encontrado.'),
                              );
                            }

                            return ListView.builder(
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
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('Erro: $err')),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[400] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 30,
          ),
        ),
      ),
    );
  }
}

```