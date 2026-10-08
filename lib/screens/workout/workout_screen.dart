import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeExerciseProvider);

    const screenText = "Tela de Treino. Tempo decorrido. Categorias Coração e Músculo. Lista de exercícios.";
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
                        if (activeState.exerciseId != null) {
                          ref.read(activeExerciseProvider.notifier).toggleExercise(activeState.exerciseId!);
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
backgroundColor: activeState.exerciseId != null
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.4),
                        child: Icon(
                          activeState.isRunning ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: () {
                        ref.read(activeExerciseProvider.notifier).stopExercise();
                      },
                      child: CircleAvatar(
                        radius: 30,
backgroundColor: activeState.exerciseId != null
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.4),
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
                    child: ref.watch(exerciciosProvider).when(
                      data: (exercicios) {
                        final filteredExercicios = exercicios.where((e) => e.categoria.nome.toLowerCase() == _selectedCategory.toLowerCase()).toList();
                        
                        if (filteredExercicios.isEmpty) {
                          return const Center(child: Text('Nenhum exercício encontrado.'));
                        }
                        
                        return ListView.builder(
                          itemCount: filteredExercicios.length,
                          itemBuilder: (context, index) {
                            final exercicio = filteredExercicios[index];
                            final isActive = activeState.exerciseId == exercicio.id;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              elevation: isActive ? 4 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isActive 
                                    ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) 
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(exercicio.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                                    if (isActive)
                                      Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exercicio.descricao, style: const TextStyle(fontSize: 16)),
                                    if (isActive) ...[
                                      const SizedBox(height: 8),
                                      Text('Em execução', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                    ],
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(isActive && activeState.isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                                  color: Theme.of(context).colorScheme.primary,
                                  iconSize: 36,
                                  onPressed: () {
                                    ref.read(activeExerciseProvider.notifier).toggleExercise(exercicio.id);
                                  },
                                ),
                                onTap: () {
                                  // Quando a Issue #9 estiver pronta, o desenvolvedor adicionará a navegação para os detalhes aqui.
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Erro: $err')),
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
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 30),
        ),
      ),
    );
  }
}

