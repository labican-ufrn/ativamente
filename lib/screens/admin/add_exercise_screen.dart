import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/exercicio.dart';
import 'exercise_form.dart';

class AddExerciseScreen extends StatelessWidget {
  const AddExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExerciseForm(
      title: 'Cadastrar Exercício',
      onSave: (Exercicio exercise) async {
        await FirebaseFirestore.instance
            .collection('Exercicios')
            .add(exercise.toJson());
      },
    );
  }
}
