import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pessoa.dart'; // We need to create/ensure this exists

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
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
      .map((snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      return Pessoa.fromJson(snapshot.data()!, snapshot.id);
    }
    return null;
  });
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  Future<void> login(String email, String password) async {
    await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
          email: email,
          password: password,
        );
  }

  Future<void> register(String name, String email, String password) async {
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
  }

  Future<void> createSecondaryUser(String name, String email, String password, String role) async {
    // We use a secondary Firebase App to create a user without signing out the current user
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'tempApp',
      options: Firebase.app().options,
    );

    try {
      final userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: email, password: password);

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
          .set(pessoa.toJson());
    } finally {
      await tempApp.delete();
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
