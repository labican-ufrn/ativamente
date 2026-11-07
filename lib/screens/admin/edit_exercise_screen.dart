import 'package:flutter/material.dart';

class EditExerciseScreen extends StatelessWidget {
  const EditExerciseScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Exercício')),
      body: Center(child: Text('Edição do exercício $exerciseId')),
    );
  }
}
