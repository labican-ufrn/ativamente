import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/providers/firestore_provider.dart';

Map<String, dynamic> _exercicioJson(String nome, int intensidade) => {
  'nome': nome,
  'descricao': 'Descrição de $nome',
  'midia': '',
  'statusRealizado': false,
  'intensidade': intensidade,
  'categoria': {'nome': 'Coracao', 'icone': 'favorite'},
  'tipo': {'nome': 'Aeróbico', 'icone': 'directions_walk'},
};

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final exercicios = firestore.collection('Exercicios');
    await exercicios.doc('leve').set(_exercicioJson('Leve', 3));
    await exercicios.doc('limite-leve').set(_exercicioJson('Limite Leve', 5));
    await exercicios.doc('moderado').set(_exercicioJson('Moderado', 7));
    await exercicios.doc('intenso').set(_exercicioJson('Intenso', 10));

    container = ProviderContainer(
      overrides: [firebaseFirestoreProvider.overrideWithValue(firestore)],
    );
    addTearDown(container.dispose);
  });

  Future<List<String>> idsFiltrados(int? filtro) async {
    // Mantém o provider vivo enquanto o stream emite.
    final sub = container.listen(
      exerciciosFiltradosProvider(filtro),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(exerciciosProvider.future);
    final value = container.read(exerciciosFiltradosProvider(filtro)).value!;
    return value.map((e) => e.id).toList()..sort();
  }

  test(
    'exerciciosProvider lê a coleção Exercicios com o id do documento',
    () async {
      final sub = container.listen(exerciciosProvider, (_, _) {});
      addTearDown(sub.close);
      final lista = await container.read(exerciciosProvider.future);

      expect(lista.map((e) => e.id), containsAll(['leve', 'moderado']));
      final leve = lista.firstWhere((e) => e.id == 'leve');
      expect(leve.nome, 'Leve');
      expect(leve.intensidade, 3);
      expect(leve.categoria.nome, 'Coracao');
    },
  );

  test('sem filtro retorna todos os exercícios', () async {
    expect(await idsFiltrados(null), [
      'intenso',
      'leve',
      'limite-leve',
      'moderado',
    ]);
  });

  test('filtro leve (<= 5) retorna intensidades de 1 a 5', () async {
    expect(await idsFiltrados(3), ['leve', 'limite-leve']);
  });

  test('filtro moderado (6 a 8) retorna intensidades de 6 a 8', () async {
    expect(await idsFiltrados(7), ['moderado']);
  });

  test('filtro intenso (>= 9) retorna intensidades de 9 a 10', () async {
    expect(await idsFiltrados(10), ['intenso']);
  });

  test('intensidadeFilterProvider começa nulo e pode ser alterado/limpo', () {
    expect(container.read(intensidadeFilterProvider), isNull);

    container.read(intensidadeFilterProvider.notifier).setIntensidade(7);
    expect(container.read(intensidadeFilterProvider), 7);

    container.read(intensidadeFilterProvider.notifier).setIntensidade(null);
    expect(container.read(intensidadeFilterProvider), isNull);
  });
}
