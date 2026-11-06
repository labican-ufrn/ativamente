import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_academia/models/pessoa.dart';
import 'package:app_academia/providers/auth_provider.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? displayName;

  @override
  final String? email;

  @override
  final String? photoURL;

  FakeUser({
    this.uid = 'uid-1',
    this.displayName,
    this.email,
    this.photoURL,
  });
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User? user;

  FakeUserCredential(this.user);
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  @override
  final String? accessToken;

  @override
  final String? idToken;

  FakeGoogleSignInAuthentication({
    this.accessToken = 'fake-access-token',
    this.idToken = 'fake-id-token',
  });
}

class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      FakeGoogleSignInAuthentication();
}

class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  final GoogleSignInAccount? accountToReturn;
  final Object? errorToThrow;
  bool signOutCalled = false;

  FakeGoogleSignIn({this.accountToReturn, this.errorToThrow});

  @override
  Future<GoogleSignInAccount?> signIn() async {
    if (errorToThrow != null) throw errorToThrow!;
    return accountToReturn;
  }

  @override
  Future<GoogleSignInAccount?> signOut() async {
    signOutCalled = true;
    return null;
  }
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final User? userToReturn;
  final FirebaseAuthException? errorToThrow;
  AuthCredential? receivedCredential;
  bool signOutCalled = false;

  FakeFirebaseAuth({this.userToReturn, this.errorToThrow});

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    receivedCredential = credential;
    if (errorToThrow != null) throw errorToThrow!;
    return FakeUserCredential(userToReturn);
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final bool exists;
  final Map<String, dynamic>? _data;

  FakeDocumentSnapshot(this._data, {required this.exists});

  @override
  Map<String, dynamic>? data() => _data;
}

// ignore: subtype_of_sealed_class, must_be_immutable
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  final FakeDocumentSnapshot snapshotToReturn;
  Map<String, dynamic>? savedData;

  FakeDocumentReference(this.snapshotToReturn);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    return snapshotToReturn;
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    savedData = data;
  }
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, FakeDocumentReference> docs = {};
  final bool documentAlreadyExists;
  final Map<String, dynamic>? existingData;

  FakeCollectionReference({
    this.documentAlreadyExists = false,
    this.existingData,
  });

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final key = path ?? 'default';
    return docs.putIfAbsent(
      key,
      () => FakeDocumentReference(
        FakeDocumentSnapshot(
          existingData,
          exists: documentAlreadyExists,
        ),
      ),
    );
  }
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final FakeCollectionReference pessoasCollection;

  FakeFirebaseFirestore({
    bool documentAlreadyExists = false,
    Map<String, dynamic>? existingData,
  }) : pessoasCollection = FakeCollectionReference(
         documentAlreadyExists: documentAlreadyExists,
         existingData: existingData,
       );

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return pessoasCollection;
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

  group('AuthController.signInWithGoogle (Issue #67)', () {
    test(
      'cria documento Pessoas automaticamente no primeiro login com Google',
      () async {
        final fakeUser = FakeUser(
          uid: 'google-uid-123',
          displayName: 'Dona Helena',
          email: 'helena@gmail.com',
          photoURL: 'https://example.com/helena.jpg',
        );
        final fakeAuth = FakeFirebaseAuth(userToReturn: fakeUser);
        final fakeFirestore = FakeFirebaseFirestore(
          documentAlreadyExists: false,
        );
        final fakeGoogleSignIn = FakeGoogleSignIn(
          accountToReturn: FakeGoogleSignInAccount(),
        );

        final container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(fakeAuth),
            firestoreProvider.overrideWithValue(fakeFirestore),
            googleSignInProvider.overrideWithValue(fakeGoogleSignIn),
          ],
        );
        addTearDown(container.dispose);

        final result = await container
            .read(authControllerProvider)
            .signInWithGoogle();

        expect(result, isTrue);
        expect(fakeAuth.receivedCredential, isNotNull);

        final savedDoc =
            fakeFirestore.pessoasCollection.docs['google-uid-123']?.savedData;
        expect(savedDoc, isNotNull);
        expect(savedDoc!['nome'], equals('Dona Helena'));
        expect(savedDoc['email'], equals('helena@gmail.com'));
        expect(savedDoc['nomeLogin'], equals('helena@gmail.com'));
        expect(savedDoc['foto'], equals('https://example.com/helena.jpg'));
        expect(savedDoc['role'], equals('user'));
        expect(savedDoc['peso'], equals(0.0));
        expect(savedDoc['altura'], equals(0.0));
      },
    );

    test(
      'nao sobrescreve documento Pessoas quando usuario ja existe no Firestore',
      () async {
        final fakeUser = FakeUser(
          uid: 'existing-uid',
          displayName: 'Seu Jorge',
          email: 'jorge@gmail.com',
        );
        final fakeAuth = FakeFirebaseAuth(userToReturn: fakeUser);
        final fakeFirestore = FakeFirebaseFirestore(
          documentAlreadyExists: true,
          existingData: {'nome': 'Jorge Antigo', 'role': 'admin'},
        );
        final fakeGoogleSignIn = FakeGoogleSignIn(
          accountToReturn: FakeGoogleSignInAccount(),
        );

        final container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(fakeAuth),
            firestoreProvider.overrideWithValue(fakeFirestore),
            googleSignInProvider.overrideWithValue(fakeGoogleSignIn),
          ],
        );
        addTearDown(container.dispose);

        final result = await container
            .read(authControllerProvider)
            .signInWithGoogle();

        expect(result, isTrue);
        expect(
          fakeFirestore.pessoasCollection.docs['existing-uid']?.savedData,
          isNull,
        );
      },
    );

    test(
      'retorna false sem autenticar quando usuario cancela selecao de conta Google',
      () async {
        final fakeAuth = FakeFirebaseAuth();
        final fakeFirestore = FakeFirebaseFirestore();
        final fakeGoogleSignIn = FakeGoogleSignIn(accountToReturn: null);

        final container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(fakeAuth),
            firestoreProvider.overrideWithValue(fakeFirestore),
            googleSignInProvider.overrideWithValue(fakeGoogleSignIn),
          ],
        );
        addTearDown(container.dispose);

        final result = await container
            .read(authControllerProvider)
            .signInWithGoogle();

        expect(result, isFalse);
        expect(fakeAuth.receivedCredential, isNull);
      },
    );

    test(
      'traduz FirebaseAuthException para mensagem amigavel em PT-BR',
      () async {
        final fakeAuth = FakeFirebaseAuth(
          errorToThrow: FirebaseAuthException(
            code: 'account-exists-with-different-credential',
          ),
        );
        final fakeFirestore = FakeFirebaseFirestore();
        final fakeGoogleSignIn = FakeGoogleSignIn(
          accountToReturn: FakeGoogleSignInAccount(),
        );

        final container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(fakeAuth),
            firestoreProvider.overrideWithValue(fakeFirestore),
            googleSignInProvider.overrideWithValue(fakeGoogleSignIn),
          ],
        );
        addTearDown(container.dispose);

        await expectLater(
          container.read(authControllerProvider).signInWithGoogle(),
          throwsA(
            isA<FirebaseAuthException>().having(
              (e) => e.message,
              'message',
              equals('Este e-mail já está vinculado a outro método de acesso.'),
            ),
          ),
        );
      },
    );
  });
}
