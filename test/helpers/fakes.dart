import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:app_academia/providers/auth_provider.dart';

/// Usuário do Firebase Auth com apenas os campos usados pelo app.
class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  FakeUser({this.uid = 'uid-teste', this.email, this.displayName});
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User? user;

  FakeUserCredential(this.user);
}

/// FirebaseAuth em memória: registra as chamadas e pode simular erro.
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  Object? erro;
  String uidCriado = 'uid-novo';
  final chamadas = <String>[];

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    chamadas.add('signIn:$email');
    if (erro != null) throw erro!;
    return FakeUserCredential(FakeUser(email: email));
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    chamadas.add('create:$email');
    if (erro != null) throw erro!;
    return FakeUserCredential(FakeUser(uid: uidCriado, email: email));
  }

  @override
  Future<void> signOut() async {
    chamadas.add('signOut');
  }
}

/// FlutterTts sem canal de plataforma: guarda a ordem das chamadas.
class FakeFlutterTts extends Fake implements FlutterTts {
  final chamadas = <String>[];

  @override
  Future<dynamic> stop() async {
    chamadas.add('stop');
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    chamadas.add('speak:$text');
    return 1;
  }
}

/// AuthController que não fala com o Firebase: registra as chamadas e pode
/// simular erro. Usado nas telas de cadastro e de adicionar usuário.
class FakeAuthController extends AuthController {
  FakeAuthController(super.ref, {this.erro});

  Object? erro;
  final chamadas = <List<String>>[];

  @override
  Future<void> register(String name, String email, String password) async {
    chamadas.add(['register', name, email, password]);
    if (erro != null) throw erro!;
  }

  @override
  Future<void> createSecondaryUser(
    String name,
    String email,
    String password,
    String role,
  ) async {
    chamadas.add(['createSecondaryUser', name, email, password, role]);
    if (erro != null) throw erro!;
  }

  @override
  Future<void> login(String email, String password) async {
    chamadas.add(['login', email, password]);
    if (erro != null) throw erro!;
  }

  @override
  Future<void> logout() async {
    chamadas.add(['logout']);
  }
}

/// Atalho para sobrescrever o AuthController com um [FakeAuthController].
Override fakeAuthControllerOverride(
  void Function(FakeAuthController) aoCriar, {
  Object? erro,
}) {
  return authControllerProvider.overrideWith((ref) {
    final controller = FakeAuthController(ref, erro: erro);
    aoCriar(controller);
    return controller;
  });
}
