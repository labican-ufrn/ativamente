import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/providers/seed_provider.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late FakeAuthController authController;
  late List<String> logs;
  late DebugPrintCallback debugPrintOriginal;

  ProviderContainer criarContainer({Object? erroAuth}) {
    final container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        fakeAuthControllerOverride((c) => authController = c, erro: erroAuth),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    logs = [];
    debugPrintOriginal = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
  });

  tearDown(() => debugPrint = debugPrintOriginal);

  test(
    'semeia os exercícios do JSON usando codigo como id do documento',
    () async {
      final esperado =
          (jsonDecode(await rootBundle.loadString('assets/data/exercises.json'))
                  as List)
              .cast<Map<String, dynamic>>();

      final container = criarContainer();
      await container.read(seedDatabaseProvider)();

      final docs = await firestore.collection('Exercicios').get();
      expect(docs.size, esperado.length);

      final primeiro = esperado.first;
      final doc = await firestore
          .collection('Exercicios')
          .doc(primeiro['codigo'] as String)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['nome'], primeiro['nome']);
      expect(logs.any((l) => l.contains('exercícios semeados')), isTrue);
    },
  );

  test('é idempotente: rodar duas vezes não duplica exercícios', () async {
    final container = criarContainer();
    await container.read(seedDatabaseProvider)();
    final primeiraVez = (await firestore.collection('Exercicios').get()).size;

    await container.read(seedDatabaseProvider)();
    final segundaVez = (await firestore.collection('Exercicios').get()).size;

    expect(segundaVez, primeiraVez);
  });

  test('cria as contas padrão de admin e personal trainer', () async {
    final container = criarContainer();
    await container.read(seedDatabaseProvider)();

    expect(authController.chamadas, [
      [
        'createSecondaryUser',
        'Admin Ativamente',
        'ativamente@ativamente.org',
        'dev123456',
        'admin',
      ],
      [
        'createSecondaryUser',
        'Personal Trainer',
        'personal@ativamente.org',
        'dev123456',
        'trainer',
      ],
    ]);
    expect(logs.last, contains('concluído'));
  });

  test(
    'falha ao criar contas (ex.: já existem) não interrompe o seed',
    () async {
      final container = criarContainer(
        erroAuth: Exception('email-already-in-use'),
      );

      await expectLater(container.read(seedDatabaseProvider)(), completes);

      expect(authController.chamadas, hasLength(2));
      expect(
        logs.where((l) => l.contains('might already exist')),
        hasLength(2),
      );
      expect(
        (await firestore.collection('Exercicios').get()).size,
        greaterThan(0),
      );
    },
  );
}
