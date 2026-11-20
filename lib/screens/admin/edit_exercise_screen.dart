import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/exercicio.dart';
import '../../providers/firestore_provider.dart';
import '../../providers/tts_provider.dart';
import 'exercise_form.dart';

class EditExerciseScreen extends ConsumerWidget {
  const EditExerciseScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(exerciciosProvider)
        .when(
          data: (exercicios) {
            Exercicio? exercise;
            for (final item in exercicios) {
              if (item.id == exerciseId) {
                exercise = item;
                break;
              }
            }
            if (exercise == null) {
              return const _ExerciseStateScreen(
                message: 'Exercício não encontrado.',
                screenText: 'Editar exercício. Exercício não encontrado.',
              );
            }

            return ExerciseForm(
              title: 'Editar Exercício',
              exercise: exercise,
              onSave: (updatedExercise) async {
                await FirebaseFirestore.instance
                    .collection('Exercicios')
                    .doc(exerciseId)
                    .update(updatedExercise.toJson());
              },
            );
          },
          loading: () => const _ExerciseStateScreen(
            message: 'Carregando exercício...',
            screenText: 'Editar exercício. Carregando exercício.',
            showProgress: true,
          ),
          error: (error, stackTrace) {
            debugPrint('Erro ao carregar exercício $exerciseId: $error');
            return const _ExerciseStateScreen(
              message:
                  'Não foi possível carregar o exercício. Tente novamente.',
              screenText:
                  'Editar exercício. Não foi possível carregar. Tente novamente.',
            );
          },
        );
  }
}

class _ExerciseStateScreen extends ConsumerWidget {
  const _ExerciseStateScreen({
    required this.message,
    required this.screenText,
    this.showProgress = false,
  });

  final String message;
  final String screenText;
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readScreen = ref.watch(readScreenProvider(screenText));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Exercício'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: readScreen,
            tooltip: 'Ler tela',
          ),
        ],
      ),
      body: Center(
        child: showProgress
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Text(message, textAlign: TextAlign.center),
              ),
      ),
    );
  }
}
