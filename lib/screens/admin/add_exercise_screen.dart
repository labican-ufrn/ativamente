import 'package:flutter/material.dart';

class AddExerciseScreen extends StatelessWidget {
  const AddExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Exercício')),
      body: const Center(child: Text('Cadastro de novo exercício')),
    );
  }
}
