import 'package:flutter_test/flutter_test.dart';
import 'package:app_academia/models/exercicio.dart';
import 'package:app_academia/core/utils/intensity.dart';

void main() {
  group('Exercicio', () {
    final categoriaValida = Categoria(nome: 'Coracao', icone: 'favorite');
    final tipoValido = Tipo(nome: 'Cardio', icone: 'directions_run');

    Exercicio criarExercicioValido({int intensidade = 1}) {
      return Exercicio(
        id: 'test-id',
        codigo: 'test-code',
        nome: 'Teste',
        descricao: 'Descrição teste',
        midia: '',
        categoria: categoriaValida,
        tipo: tipoValido,
        intensidade: intensidade,
      );
    }

    test('construtor aceita intensidade válida de 1 a 10', () {
      for (var i = 1; i <= 10; i++) {
        expect(() => criarExercicioValido(intensidade: i), returnsNormally, reason: 'Intensidade $i deve ser aceita');
      }
    });

    test('construtor falha com assert quando intensidade < 1', () {
      expect(() => criarExercicioValido(intensidade: 0), throwsAssertionError);
      expect(() => criarExercicioValido(intensidade: -1), throwsAssertionError);
    });

    test('construtor falha com assert quando intensidade > 10', () {
      expect(() => criarExercicioValido(intensidade: 11), throwsAssertionError);
      expect(() => criarExercicioValido(intensidade: 100), throwsAssertionError);
    });

    test('fromJson/toJson roundtrip preserva intensidade', () {
      const intensidadeTeste = 7;
      final exOriginal = criarExercicioValido(intensidade: intensidadeTeste);
      final json = exOriginal.toJson();
      final exRestaurado = Exercicio.fromJson(json, 'test-id');
      
      expect(exRestaurado.intensidade, intensidadeTeste);
      expect(exRestaurado.nome, exOriginal.nome);
      expect(exRestaurado.codigo, exOriginal.codigo);
      expect(exRestaurado.descricao, exOriginal.descricao);
      expect(exRestaurado.midia, exOriginal.midia);
      expect(exRestaurado.statusRealizado, exOriginal.statusRealizado);
      expect(exRestaurado.categoria.nome, exOriginal.categoria.nome);
      expect(exRestaurado.tipo.nome, exOriginal.tipo.nome);
    });

    test('fromJson usa intensidade padrão 1 quando ausente no JSON', () {
      final json = {
        'codigo': 'test',
        'nome': 'Teste',
        'descricao': 'Descrição',
        'midia': '',
        'statusRealizado': false,
        'categoria': {'nome': 'Coracao', 'icone': 'favorite'},
        'tipo': {'nome': 'Cardio', 'icone': 'directions_run'},
      };
      final ex = Exercicio.fromJson(json, 'test-id');
      expect(ex.intensidade, 1);
    });

    test('toJson inclui intensidade no mapa', () {
      final ex = criarExercicioValido(intensidade: 8);
      final json = ex.toJson();
      expect(json['intensidade'], 8);
    });
  });

  group('rotuloIntensidade', () {
    test('retorna Leve para intensidade 1-5', () {
      expect(rotuloIntensidade(1), 'Leve');
      expect(rotuloIntensidade(2), 'Leve');
      expect(rotuloIntensidade(3), 'Leve');
      expect(rotuloIntensidade(4), 'Leve');
      expect(rotuloIntensidade(5), 'Leve');
    });

    test('retorna Moderado para intensidade 6-8', () {
      expect(rotuloIntensidade(6), 'Moderado');
      expect(rotuloIntensidade(7), 'Moderado');
      expect(rotuloIntensidade(8), 'Moderado');
    });

    test('retorna Intenso para intensidade 9-10', () {
      expect(rotuloIntensidade(9), 'Intenso');
      expect(rotuloIntensidade(10), 'Intenso');
    });

    test('retorna Intenso para valores > 10 (comportamento defensivo)', () {
      expect(rotuloIntensidade(11), 'Intenso');
      expect(rotuloIntensidade(100), 'Intenso');
    });

    test('retorna Intenso para valores < 1 (comportamento defensivo)', () {
      expect(rotuloIntensidade(0), 'Intenso');
      expect(rotuloIntensidade(-5), 'Intenso');
    });
  });
}