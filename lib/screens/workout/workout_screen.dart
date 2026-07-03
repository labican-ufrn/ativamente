import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _formatTime(_seconds),
                  style: const TextStyle(
                    color: Colors.white,
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
                        backgroundColor: Colors.white,
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
                        backgroundColor: Colors.white,
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
                            return _buildExerciseTile(exercicio.nome, exercicio.descricao);
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
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildExerciseTile(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to exercise details
        },
      ),
    );
  }
}
