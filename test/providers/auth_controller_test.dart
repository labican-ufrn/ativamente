import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/firestore_provider.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FakeFirebaseAuth auth;

  ProviderContainer criarContainer({User? usuarioLogado}) {
    final container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        firebaseAuthProvider.overrideWithValue(auth),
        authStateProvider.overrideWith((ref) => Stream.value(usuarioLogado)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = FakeFirebaseAuth();
  });

  group('AuthController.login', () {
    test('autentica com e-mail e senha', () async {
      final container = criarContainer();

      await container.read(authControllerProvider).login('a@b.com', '123456');

      expect(auth.chamadas, ['signIn:a@b.com']);
    });

    test(
      'FirebaseAuthException recebe mensagem amigável preservando o code',
      () async {
        auth.erro = FirebaseAuthException(code: 'wrong-password');
        final container = criarContainer();

        await expectLater(
          container.read(authControllerProvider).login('a@b.com', 'x'),
          throwsA(
            isA<FirebaseAuthException>()
                .having((e) => e.code, 'code', 'wrong-password')
                .having(
                  (e) => e.message,
                  'message',
                  'Senha incorreta. Tente novamente.',
                ),
          ),
        );
      },
    );

    test('outros erros viram Exception com mensagem amigável', () async {
      auth.erro = Exception('network-request-failed');
      final container = criarContainer();

      await expectLater(
        container.read(authControllerProvider).login('a@b.com', 'x'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'mensagem',
            contains('Falha na conexão de rede'),
          ),
        ),
      );
    });
  });

  group('AuthController.register', () {
    test('cria a conta e grava o documento Pessoas com role user', () async {
      auth.uidCriado = 'uid-maria';
      final container = criarContainer();

      await container
          .read(authControllerProvider)
          .register('Maria', 'maria@b.com', '123456');

      final doc = await firestore.collection('Pessoas').doc('uid-maria').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['nome'], 'Maria');
      expect(doc.data()!['nomeLogin'], 'maria@b.com');
      expect(doc.data()!['role'], 'user');
    });

    test(
      'e-mail já cadastrado gera mensagem amigável e não grava Pessoas',
      () async {
        auth.erro = FirebaseAuthException(code: 'email-already-in-use');
        final container = criarContainer();

        await expectLater(
          container
              .read(authControllerProvider)
              .register('Maria', 'maria@b.com', '123456'),
          throwsA(
            isA<FirebaseAuthException>().having(
              (e) => e.message,
              'message',
              'Este e-mail já está cadastrado.',
            ),
          ),
        );
        expect((await firestore.collection('Pessoas').get()).size, 0);
      },
    );

    test('erro genérico vira Exception amigável', () async {
      auth.erro = StateError('falhou');
      final container = criarContainer();

      await expectLater(
        container
            .read(authControllerProvider)
            .register('Maria', 'maria@b.com', '123456'),
        throwsA(isA<Exception>()),
      );
    });
  });

  test('logout encerra a sessão no FirebaseAuth injetado', () async {
    final container = criarContainer();

    await container.read(authControllerProvider).logout();

    expect(auth.chamadas, ['signOut']);
  });

  group('userDataProvider', () {
    Future<dynamic> lerPessoa(ProviderContainer container) async {
      final sub = container.listen(userDataProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(authStateProvider.future);
      // Aguarda o stream do Firestore emitir após o usuário ser conhecido.
      for (var i = 0; i < 20; i++) {
        final valor = container.read(userDataProvider);
        if (valor.hasValue && valor.value != null) return valor.value;
        await Future<void>.delayed(Duration.zero);
      }
      return container.read(userDataProvider).value;
    }

    test('sem usuário logado emite null', () async {
      final container = criarContainer();
      final sub = container.listen(userDataProvider, (_, _) {});
      addTearDown(sub.close);

      expect(await container.read(userDataProvider.future), isNull);
    });

    test('lê o documento Pessoas do usuário logado', () async {
      await firestore.collection('Pessoas').doc('uid-1').set({
        'nome': 'João',
        'role': 'trainer',
        'peso': 80,
      });
      final container = criarContainer(
        usuarioLogado: FakeUser(uid: 'uid-1', email: 'joao@b.com'),
      );

      final pessoa = await lerPessoa(container);

      expect(pessoa.id, 'uid-1');
      expect(pessoa.nome, 'João');
      expect(pessoa.role, 'trainer');
      expect(pessoa.peso, 80.0);
      expect(container.read(userDisplayNameProvider), 'João');
    });

    test(
      'auto-cria Pessoas sem gravar role quando o documento não existe',
      () async {
        final container = criarContainer(
          usuarioLogado: FakeUser(uid: 'uid-2', email: 'ana.souza@b.com'),
        );

        final pessoa = await lerPessoa(container);

        expect(pessoa.nome, 'ana.souza');
        expect(pessoa.nomeLogin, 'ana.souza@b.com');

        final doc = await firestore.collection('Pessoas').doc('uid-2').get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['nome'], 'ana.souza');
        expect(doc.data()!.containsKey('role'), isFalse);
      },
    );
  });
}
