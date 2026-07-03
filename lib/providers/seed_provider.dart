import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercicio.dart';
import 'auth_provider.dart';

final seedDatabaseProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final firestore = FirebaseFirestore.instance;
    final exerciciosCollection = firestore.collection('Exercicios');

    final mockExercicios = [
      Exercicio(
        id: '', // Firestore will generate this
        nome: 'Polichinelo',
        descricao: '10 min',
        midia: '',
        categoria: Categoria(nome: 'Coracao', icone: 'favorite'),
        tipo: Tipo(nome: 'Cardio', icone: 'directions_run'),
      ),
      Exercicio(
        id: '',
        nome: 'Caminhada',
        descricao: '15 min',
        midia: '',
        categoria: Categoria(nome: 'Coracao', icone: 'favorite'),
        tipo: Tipo(nome: 'Cardio', icone: 'directions_run'),
      ),
      Exercicio(
        id: '',
        nome: 'Flexão',
        descricao: '3x de 10 repetições',
        midia: '',
        categoria: Categoria(nome: 'Musculo', icone: 'fitness_center'),
        tipo: Tipo(nome: 'Força', icone: 'fitness_center'),
      ),
      Exercicio(
        id: '',
        nome: 'Agachamento',
        descricao: '4x de 12 repetições',
        midia: '',
        categoria: Categoria(nome: 'Musculo', icone: 'fitness_center'),
        tipo: Tipo(nome: 'Força', icone: 'fitness_center'),
      ),
    ];

    for (var exercicio in mockExercicios) {
      await exerciciosCollection.add(exercicio.toJson());
    }

    // Seed Admin
    try {
      await ref.read(authControllerProvider).createSecondaryUser(
        'Admin Ativamente',
        'ativamente@ativamente.org',
        'dev123456',
        'admin',
      );
    } catch (e) {
      debugPrint('Admin user might already exist or error: $e');
    }

    // Seed Trainer
    try {
      await ref.read(authControllerProvider).createSecondaryUser(
        'Personal Trainer',
        'personal@ativamente.org',
        'dev123456',
        'trainer',
      );
    } catch (e) {
      debugPrint('Trainer user might already exist or error: $e');
    }
  };
});
