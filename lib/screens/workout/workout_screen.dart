import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/intensity.dart';
import '../../models/exercicio.dart';
import '../../providers/tts_provider.dart';
import '../../providers/firestore_provider.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  String _selectedCategory = 'Coracao'; // Coracao or Musculo

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _seconds++;
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _seconds = 0;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _filterByIntensity(int? intensidade) {
    ref.read(intensidadeFilterProvider.notifier).setIntensidade(intensidade);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIntensity = ref.watch(intensidadeFilterProvider);
    final hasIntensityFilter = selectedIntensity != null;
    final screenText = hasIntensityFilter
        ? 'Tela de Treino. Tempo decorrido. Categorias Coração e Músculo. Filtrado por intensidade ${rotuloIntensidade(selectedIntensity!)}. Lista de exercícios.'
        : 'Tela de Treino. Tempo decorrido. Categorias Coração e Músculo. Exercícios com níveis Leve, Moderado e Intenso. Lista de exercícios.';
    final readScreen = ref.watch(readScreenProvider(screenText));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Voltar', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  _formatTime(_seconds),
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
                      onTap: _toggleTimer,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        child: Icon(
                          _isRunning ? Icons.pause : Icons.play_arrow,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: _stopTimer,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
                    context: context,
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
                    child: ref.watch(exerciciosFiltradosProvider(selectedIntensity)).when(
                      data: (exercicios) {
                        final filteredExercicios = exercicios.where((e) => e.categoria.nome.toLowerCase() == _selectedCategory.toLowerCase()).toList();
                        
                        if (filteredExercicios.isEmpty) {
                          return const Center(child: Text('Nenhum exercício encontrado.'));
                        }
                        
                        return ListView.builder(
                          itemCount: filteredExercicios.length,
                          itemBuilder: (context, index) {
                            final exercicio = filteredExercicios[index];
                            return _buildExerciseTile(exercicio);
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

  Widget _buildExerciseTile(Exercicio exercicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(exercicio.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(exercicio.descricao, style: const TextStyle(fontSize: 16)),
        trailing: intensityChip(
          context: context,
          intensidade: exercicio.intensidade,
          onPressed: () => _filterByIntensity(exercicio.intensidade),
        ),
        onTap: () {
          // Navigate to exercise details
        },
      ),
    );
  }
}
