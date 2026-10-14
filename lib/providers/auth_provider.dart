import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_environment.dart';
import '../models/pessoa.dart';
import '../utils/auth_errors.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Retorna o nome de exibição do usuário aplicando precedência com fallback robusto:
/// 1. Pessoa.nome (se preenchido)
/// 2. User.displayName do Firebase Auth (se preenchido)
/// 3. Prefixo do e-mail do Firebase Auth
/// 4. Fallback genérico 'Usuário'
String getEffectiveDisplayName(Pessoa? pessoa, User? user) {
  if (pessoa != null && pessoa.nome.trim().isNotEmpty) {
    return pessoa.nome.trim();
  }
  if (user != null) {
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    if (user.email != null && user.email!.trim().isNotEmpty) {
      final emailPrefix = user.email!.split('@').first.trim();
      if (emailPrefix.isNotEmpty) {
        return emailPrefix;
      }
    }
  }
  return 'Usuário';
}

final userDisplayNameProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).value;
  final pessoa = ref.watch(userDataProvider).value;
  return getEffectiveDisplayName(pessoa, user);
});

final userDataProvider = StreamProvider<Pessoa?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(null);
  }
  return FirebaseFirestore.instance
      .collection('Pessoas')
      .doc(user.uid)
      .snapshots()
      .asyncMap((snapshot) async {
    if (snapshot.exists && snapshot.data() != null) {
      return Pessoa.fromJson(snapshot.data()!, snapshot.id);
    }
    // Auto-criação on-demand para contas sem documento Pessoas no Firestore
    final fallbackName = getEffectiveDisplayName(null, user);
    final newPessoa = Pessoa(
      id: user.uid,
      nome: fallbackName,
      nomeLogin: user.email ?? '',
      role: 'user',
      dataNascimento: '',
      peso: 0.0,
      altura: 0.0,
      notificacoes: [],
    );
    try {
      await FirebaseFirestore.instance
          .collection('Pessoas')
          .doc(user.uid)
          .set(newPessoa.toJson(), SetOptions(merge: true));
    } catch (_) {
      // Ignora falhas de escrita (ex.: offline/regras em execução local)
    }
    return newPessoa;
  });
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<void> login(String email, String password) async {
    try {
      await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: getFriendlyErrorMessage(e),
      );
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final userCredential = await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
      
      // Create the Pessoa document in Firestore
      if (userCredential.user != null) {
        final pessoa = Pessoa(
          id: userCredential.user!.uid,
          nome: name,
          nomeLogin: email, // Assuming email is used as login
          dataNascimento: '', // Placeholder, update in profile
          peso: 0.0,
          altura: 0.0,
          notificacoes: [],
        );
        await FirebaseFirestore.instance
            .collection('Pessoas')
            .doc(userCredential.user!.uid)
            .set(pessoa.toJson());
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: getFriendlyErrorMessage(e),
      );
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  static FirebaseApp? _tempApp;

  static Future<FirebaseAuth> _getTempAuth() async {
    if (_tempApp == null) {
      try {
        _tempApp = Firebase.app('tempApp');
      } catch (_) {
        _tempApp = await Firebase.initializeApp(
          name: 'tempApp',
          options: Firebase.app().options,
        );
      }
      final tempAuth = FirebaseAuth.instanceFor(app: _tempApp!);
      if (AppEnvironment.useEmulators) {
        await tempAuth.useAuthEmulator(
          AppEnvironment.emulatorHost,
          AppEnvironment.authPort,
        );
      }
      return tempAuth;
    }
    return FirebaseAuth.instanceFor(app: _tempApp!);
  }

  Future<void> createSecondaryUser(String name, String email, String password, String role) async {
    try {
      final tempAuth = await _getTempAuth();
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final pessoa = Pessoa(
          id: userCredential.user!.uid,
          nome: name,
          role: role,
          nomeLogin: email,
          dataNascimento: '',
          peso: 0.0,
          altura: 0.0,
          notificacoes: [],
        );

        await FirebaseFirestore.instance
            .collection('Pessoas')
            .doc(userCredential.user!.uid)
            .set(pessoa.toJson(), SetOptions(merge: true));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' || e.code == 'EMAIL_EXISTS') {
        return;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
