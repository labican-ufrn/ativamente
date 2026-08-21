import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/app_environment.dart';
import 'firebase_options.dart';
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

class AppAcademia extends ConsumerWidget {
  const AppAcademia({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'App Academia',
      theme: AppTheme.theme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
