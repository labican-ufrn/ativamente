import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/models/treino_sugerido.dart';

void main() {
  group('TreinoSugerido', () {
    test('construtor aplica valores padrão', () {
      final treino = TreinoSugerido(id: 't1', titulo: 'Manhã leve');

      expect(treino.numRepeticao, 0);
      expect(treino.numSerie, 0);
      expect(treino.tempoMedio, '');
      expect(treino.dificuldade, '');
      expect(treino.exerciciosIds, isEmpty);
    });

    test('fromJson lê os campos e a lista exercicios_ids', () {
      final treino = TreinoSugerido.fromJson({
        'titulo': 'Manhã leve',
        'numRepeticao': 10,
        'numSerie': 3,
        'tempoMedio': '20 min',
        'dificuldade': 'Leve',
        'exercicios_ids': ['ex-1', 'ex-2'],
      }, 't1');

      expect(treino.id, 't1');
      expect(treino.titulo, 'Manhã leve');
      expect(treino.numRepeticao, 10);
      expect(treino.numSerie, 3);
      expect(treino.tempoMedio, '20 min');
      expect(treino.dificuldade, 'Leve');
      expect(treino.exerciciosIds, ['ex-1', 'ex-2']);
    });

    test('fromJson com mapa vazio usa padrões seguros', () {
      final treino = TreinoSugerido.fromJson({}, 't2');

      expect(treino.id, 't2');
      expect(treino.titulo, '');
      expect(treino.numRepeticao, 0);
      expect(treino.exerciciosIds, isEmpty);
    });

    test('toJson usa a chave exercicios_ids e preserva os dados', () {
      final treino = TreinoSugerido(
        id: 't1',
        titulo: 'Tarde',
        numRepeticao: 8,
        numSerie: 2,
        tempoMedio: '15 min',
        dificuldade: 'Moderado',
        exerciciosIds: const ['ex-3'],
      );

      final json = treino.toJson();

      expect(json, {
        'titulo': 'Tarde',
        'numRepeticao': 8,
        'numSerie': 2,
        'tempoMedio': '15 min',
        'dificuldade': 'Moderado',
        'exercicios_ids': ['ex-3'],
      });
      expect(TreinoSugerido.fromJson(json, 't1').toJson(), json);
    });
  });
}
