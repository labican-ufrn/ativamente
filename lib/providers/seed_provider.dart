import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

final seedDatabaseProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final firestore = FirebaseFirestore.instance;
    final exerciciosCollection = firestore.collection('Exercicios');

    debugPrint('🌱 [Seed] Iniciando povoamento de exercícios e usuários padrão...');
    try {
      final jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          final codigo = item['codigo'] as String? ?? '';
          if (codigo.isNotEmpty) {
            await exerciciosCollection.doc(codigo).set(item, SetOptions(merge: true));
          } else {
            await exerciciosCollection.add(item);
          }
        }
      }
      debugPrint('✅ [Seed] ${jsonList.length} exercícios semeados/atualizados no Firestore.');
    } catch (e) {
      debugPrint('❌ Erro ao carregar ou semear exercises.json: $e');
    }

    // Seed Admin
    try {
      await ref.read(authControllerProvider).createSecondaryUser(
        'Admin Ativamente',
        'ativamente@ativamente.org',
        'dev123456',
        'admin',
      );
      debugPrint('✅ [Seed] Usuário Admin verificado/criado.');
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
      debugPrint('✅ [Seed] Usuário Personal Trainer verificado/criado.');
    } catch (e) {
      debugPrint('Trainer user might already exist or error: $e');
    }
    debugPrint('🎉 [Seed] Processo de seed concluído com sucesso!');
  };
});

