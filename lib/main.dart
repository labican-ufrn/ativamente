import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/app_environment.dart';
import 'firebase_options.dart';
import 'providers/seed_provider.dart';
import 'routes.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (AppEnvironment.useEmulators) {
    await FirebaseAuth.instance.useAuthEmulator(
      AppEnvironment.emulatorHost,
      AppEnvironment.authPort,
    );
    FirebaseFirestore.instance.useFirestoreEmulator(
      AppEnvironment.emulatorHost,
      AppEnvironment.firestorePort,
    );
  }

  runApp(
    const ProviderScope(
      child: AppAcademia(),
    ),
  );
}

class AppAcademia extends ConsumerStatefulWidget {
  const AppAcademia({super.key});

  @override
  ConsumerState<AppAcademia> createState() => _AppAcademiaState();
}

class _AppAcademiaState extends ConsumerState<AppAcademia> {
  @override
  void initState() {
    super.initState();
    // Executa seed automático e idempotente assim que a árvore de widgets estiver montada e o rootBundle de assets pronto
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(seedDatabaseProvider)();
      } catch (e) {
        debugPrint('Erro no seed automático de inicialização: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'App Academia',
      theme: AppTheme.theme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
