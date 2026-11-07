// ignore_for_file: subtype_of_sealed_class, must_be_immutable

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_academia/models/pessoa.dart';
import 'package:app_academia/providers/auth_provider.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? displayName;

  @override
  final String? email;

  FakeUser({this.uid = 'user-123', this.displayName, this.email});
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User? user;

  FakeUserCredential({this.user});
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  User? currentUserMock;
  bool signedOut = false;
  Future<UserCredential> Function(String email, String password)? onSignIn;

  @override
  User? get currentUser => currentUserMock;

  @override
  Stream<User?> authStateChanges() => Stream.value(currentUserMock);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (onSignIn != null) {
      return onSignIn!(email, password);
    }
    return FakeUserCredential(
      user: FakeUser(uid: 'user-123', email: email),
    );
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

class FakeDocumentSnapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, dynamic>? snapshotData;
  @override
  final bool exists;

  FakeDocumentSnapshot({
    required this.id,
    this.snapshotData,
    this.exists = true,
  });

  @override
  Map<String, dynamic>? data() => snapshotData;
}

class FakeDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  Map<String, dynamic>? documentData;
  bool documentExists;
  int setCallCount = 0;
  Map<String, dynamic>? lastSetData;
  SetOptions? lastSetOptions;
  bool shouldThrowOnSet = false;

  final StreamController<DocumentSnapshot<Map<String, dynamic>>> _controller =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();

  FakeDocumentReference({
    required this.id,
    this.documentData,
    this.documentExists = true,
  });

  FakeDocumentSnapshot _createSnapshot() {
    return FakeDocumentSnapshot(
      id: id,
      snapshotData: documentData,
      exists: documentExists,
    );
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    late StreamController<DocumentSnapshot<Map<String, dynamic>>> controller;
    StreamSubscription? sub;
    controller = StreamController<DocumentSnapshot<Map<String, dynamic>>>(
      onListen: () {
        controller.add(_createSnapshot());
        sub = _controller.stream.listen(controller.add);
      },
      onCancel: () {
        sub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return _createSnapshot();
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    setCallCount++;
    if (shouldThrowOnSet) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Falha de rede simulada',
      );
    }
    lastSetData = data;
    lastSetOptions = options;
    documentData = data;
    documentExists = true;
    _controller.add(_createSnapshot());
  }
}

class FakeCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  final Map<String, FakeDocumentReference> docs = {};

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final docId = path ?? 'default-id';
    return docs.putIfAbsent(
      docId,
      () => FakeDocumentReference(id: docId, documentExists: false),
    );
  }
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, FakeCollectionReference> collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return collections.putIfAbsent(
      collectionPath,
      () => FakeCollectionReference(),
    );
  }
}

void main() {
  group('getEffectiveDisplayName', () {
    test('retorna nome de Pessoa quando preenchido', () {
      final pessoa = Pessoa(id: '1', nome: 'Maria Silva');
      final user = FakeUser(displayName: 'Maria Auth', email: 'maria@test.com');

      expect(getEffectiveDisplayName(pessoa, user), equals('Maria Silva'));
    });

    test('usa displayName de User quando pessoa for nula ou tiver nome vazio', () {
      final pessoaVazia = Pessoa(id: '1', nome: '   ');
      final user = FakeUser(displayName: 'João Auth', email: 'joao@test.com');

      expect(getEffectiveDisplayName(null, user), equals('João Auth'));
      expect(getEffectiveDisplayName(pessoaVazia, user), equals('João Auth'));
    });

    test('usa prefixo do e-mail quando pessoa.nome e user.displayName forem nulos/vazios', () {
      final user = FakeUser(displayName: '', email: 'carlos.dev@ativamente.org');

      expect(getEffectiveDisplayName(null, user), equals('carlos.dev'));
    });

    test('retorna Usuário quando todas as fontes forem nulas ou em branco', () {
      final user = FakeUser(displayName: '', email: '');

      expect(getEffectiveDisplayName(null, user), equals('Usuário'));
      expect(getEffectiveDisplayName(null, null), equals('Usuário'));
    });
  });

  group('firebaseFirestoreProvider & userDataProvider (leitura pura)', () {
    test('firebaseFirestoreProvider pode ser injetado e sobrescrito via ProviderContainer', () {
      final fakeFirestore = FakeFirebaseFirestore();
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(firebaseFirestoreProvider), equals(fakeFirestore));
    });

    test('userDataProvider emite null quando authStateProvider for null', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = FakeFirebaseAuth()..currentUserMock = null;
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(userDataProvider.future);
      expect(result, isNull);
    });

    test('userDataProvider realiza leitura pura e mapeia Pessoa quando documento existe no Firestore', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = FakeFirebaseAuth()
        ..currentUserMock = FakeUser(uid: 'user-123', email: 'florinda@test.com');
      final col = fakeFirestore.collection('Pessoas') as FakeCollectionReference;
      final docRef = col.doc('user-123') as FakeDocumentReference;
      docRef.documentExists = true;
      docRef.documentData = {
        'nome': 'Dona Florinda',
        'role': 'user',
        'nomeLogin': 'florinda@test.com',
      };

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);

      final pessoa = await container.read(userDataProvider.future);
      expect(pessoa, isNotNull);
      expect(pessoa!.id, equals('user-123'));
      expect(pessoa.nome, equals('Dona Florinda'));
      expect(pessoa.role, equals('user'));
      // Garante que o provider não realizou nenhuma escrita (efeito colateral)
      expect(docRef.setCallCount, equals(0));
    });

    test('userDataProvider realiza leitura pura sem efeitos colaterais de escrita quando documento nao existe', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = FakeFirebaseAuth()
        ..currentUserMock = FakeUser(uid: 'user-inexistente', email: 'inexistente@test.com');
      final col = fakeFirestore.collection('Pessoas') as FakeCollectionReference;
      final docRef = col.doc('user-inexistente') as FakeDocumentReference;
      docRef.documentExists = false;

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);

      final pessoa = await container.read(userDataProvider.future);
      expect(pessoa, isNull);
      // Confirma que não houve chamada de escrita on-demand dentro da stream
      expect(docRef.setCallCount, equals(0));
    });
  });

  group('AuthController (inicialização pós-login e injeção)', () {
    test('signIn e login inicializam o perfil on-demand quando o documento nao existe no Firestore', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = FakeFirebaseAuth();
      final fakeUser = FakeUser(uid: 'user-pos-login', email: 'novo@test.com', displayName: 'Novo Usuário');
      fakeAuth.currentUserMock = fakeUser;
      fakeAuth.onSignIn = (email, password) async => FakeUserCredential(user: fakeUser);

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);

      final col = fakeFirestore.collection('Pessoas') as FakeCollectionReference;
      final docRef = col.doc('user-pos-login') as FakeDocumentReference;
      expect(docRef.documentExists, isFalse);

      await container.read(authControllerProvider).signIn('novo@test.com', 'senha123');

      expect(docRef.setCallCount, equals(1));
      expect(docRef.lastSetOptions?.merge, isTrue);
      expect(docRef.lastSetData?['nome'], equals('Novo Usuário'));
      expect(docRef.lastSetData?['nomeLogin'], equals('novo@test.com'));
    });

    test('signIn nao sobrescreve perfil quando documento ja existe no Firestore', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = FakeFirebaseAuth();
      final fakeUser = FakeUser(uid: 'user-existente', email: 'existente@test.com');
      fakeAuth.currentUserMock = fakeUser;
      fakeAuth.onSignIn = (email, password) async => FakeUserCredential(user: fakeUser);

      final col = fakeFirestore.collection('Pessoas') as FakeCollectionReference;
      final docRef = col.doc('user-existente') as FakeDocumentReference;
      docRef.documentExists = true;
      docRef.documentData = {
        'nome': 'Usuário Existente',
        'role': 'user',
      };

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider).login('existente@test.com', 'senha123');

      expect(docRef.setCallCount, equals(0));
      expect(docRef.documentData?['nome'], equals('Usuário Existente'));
    });

    test('signIn e resiliente a falhas de rede na gravacao de perfil', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final fakeAuth = FakeFirebaseAuth();
      final fakeUser = FakeUser(uid: 'user-sem-rede', email: 'offline@test.com');
      fakeAuth.onSignIn = (email, password) async => FakeUserCredential(user: fakeUser);

      final col = fakeFirestore.collection('Pessoas') as FakeCollectionReference;
      final docRef = col.doc('user-sem-rede') as FakeDocumentReference;
      docRef.shouldThrowOnSet = true;

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);

      // Não deve lançar exceção mesmo com falha de escrita no Firestore
      await expectLater(
        container.read(authControllerProvider).signIn('offline@test.com', 'senha123'),
        completes,
      );
    });

    test('logout executa signOut no firebaseAuthProvider', () async {
      final fakeAuth = FakeFirebaseAuth();
      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);

      expect(fakeAuth.signedOut, isFalse);
      await container.read(authControllerProvider).logout();
      expect(fakeAuth.signedOut, isTrue);
    });
  });
}
