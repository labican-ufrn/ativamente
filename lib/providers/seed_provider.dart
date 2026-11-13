import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/app_environment.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

final seedDatabaseProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // Proteção de segurança: o seed NUNCA deve ser executado em produção ou conectado ao Firebase em nuvem
    if (!kDebugMode || (!AppEnvironment.useEmulators && Firebase.apps.isNotEmpty)) {
      debugPrint('⛔ [Seed] Operação cancelada: o povoamento automático só é permitido em ambiente de desenvolvimento (debug) com emuladores locais ativos.');
      return;
    }

    final firestore = ref.read(firebaseFirestoreProvider);
    final auth = Firebase.apps.isNotEmpty ? ref.read(firebaseAuthProvider) : null;
    final exerciciosCollection = firestore.collection('Exercicios');

    debugPrint('🌱 [Seed] Iniciando povoamento de exercícios e usuários padrão no emulador...');

    final initialUser = auth?.currentUser;
    bool loggedInForSeed = false;

    // 1. Assegura criação da conta Admin de teste
    try {
      await ref.read(authControllerProvider).createSecondaryUser(
        'Admin Ativamente',
        AppEnvironment.seedAdminEmail,
        AppEnvironment.seedAdminPassword,
        'admin',
      );
      debugPrint('✅ [Seed] Usuário Admin verificado/criado.');
    } catch (e) {
      debugPrint('Admin user might already exist or info: $e');
    }

    // 2. Se não houver sessão ativa, autentica temporariamente como Admin para satisfazer as regras de segurança do Firestore
    if (auth != null && auth.currentUser == null) {
      try {
        await auth.signInWithEmailAndPassword(
          email: AppEnvironment.seedAdminEmail,
          password: AppEnvironment.seedAdminPassword,
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
        AppEnvironment.seedTrainerEmail,
        AppEnvironment.seedTrainerPassword,
        'trainer',
      );
      debugPrint('✅ [Seed] Usuário Personal Trainer verificado/criado.');
    } catch (e) {
      debugPrint('Trainer user might already exist or info: $e');
    }

    // 5. Restaura o estado da sessão original caso tenha logado apenas para o seed
    if (loggedInForSeed && initialUser == null && auth != null) {
      await auth.signOut();
      debugPrint('🔓 [Seed] Sessão temporária de seed finalizada.');
    }

    debugPrint('🎉 [Seed] Processo de seed concluído com sucesso!');
  };
});
