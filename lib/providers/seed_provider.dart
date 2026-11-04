import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_provider.dart';

final seedDatabaseProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final exerciciosCollection = firestore.collection('Exercicios');

    debugPrint('🌱 [Seed] Iniciando povoamento de exercícios e usuários padrão...');

    final initialUser = auth.currentUser;
    bool loggedInForSeed = false;

    // 1. Assegura criação da conta Admin de teste
    try {
      await ref.read(authControllerProvider).createSecondaryUser(
        'Admin Ativamente',
        'ativamente@ativamente.org',
        'dev123456',
        'admin',
      );
      debugPrint('✅ [Seed] Usuário Admin verificado/criado.');
    } catch (e) {
      debugPrint('Admin user might already exist or info: $e');
    }

    // 2. Se não houver sessão ativa, autentica temporariamente como Admin para satisfazer as regras de segurança do Firestore
    if (auth.currentUser == null) {
      try {
        await auth.signInWithEmailAndPassword(
          email: 'ativamente@ativamente.org',
          password: 'dev123456',
        );
        loggedInForSeed = true;
        debugPrint('🔐 [Seed] Autenticado como Admin para povoamento seguro.');
      } catch (e) {
        debugPrint('⚠️ [Seed] Não foi possível autenticar como Admin para o seed: $e');
      }
    }

    // 3. Povoa o catálogo de exercícios com permissão de Admin
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

    // 4. Cria conta de Personal Trainer de teste
    try {
      await ref.read(authControllerProvider).createSecondaryUser(
        'Personal Trainer',
        'personal@ativamente.org',
        'dev123456',
        'trainer',
      );
      debugPrint('✅ [Seed] Usuário Personal Trainer verificado/criado.');
    } catch (e) {
      debugPrint('Trainer user might already exist or info: $e');
    }

    // 5. Restaura o estado da sessão original caso tenha logado apenas para o seed
    if (loggedInForSeed && initialUser == null) {
      await auth.signOut();
      debugPrint('🔓 [Seed] Sessão temporária de seed finalizada.');
    }

    debugPrint('🎉 [Seed] Processo de seed concluído com sucesso!');
  };
});
