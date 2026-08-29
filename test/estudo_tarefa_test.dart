import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_academia/models/tarefa_estudo.dart';

void main() {
  group('TarefaEstudo Model Tests', () {
    test('deve criar instancia de TarefaEstudo corretamente', () {
      final tarefa = TarefaEstudo(
        id: '123',
        titulo: 'Estudar Flutter',
        descricao: 'Praticar widgets e Riverpod',
        concluida: false,
      );

      expect(tarefa.id, equals('123'));
      expect(tarefa.titulo, equals('Estudar Flutter'));
      expect(tarefa.descricao, equals('Praticar widgets e Riverpod'));
      expect(tarefa.concluida, isFalse);
    });

    test('deve converter de json para TarefaEstudo', () {
      final json = {
        'titulo': 'Estudar Firebase',
        'descricao': 'Firestore CRUD e Auth',
        'concluida': true,
        'criadoEm': '2026-08-29T20:00:00.000Z',
      };

      final tarefa = TarefaEstudo.fromJson(json, 'doc_456');

      expect(tarefa.id, equals('doc_456'));
      expect(tarefa.titulo, equals('Estudar Firebase'));
      expect(tarefa.descricao, equals('Firestore CRUD e Auth'));
      expect(tarefa.concluida, isTrue);
      expect(tarefa.criadoEm, isNotNull);
    });

    test('deve converter TarefaEstudo para json', () {
      final data = DateTime(2026, 8, 29, 20, 0);
      final tarefa = TarefaEstudo(
        id: 'doc_789',
        titulo: 'Testar Auth',
        descricao: 'Login por email e senha',
        concluida: false,
        criadoEm: data,
      );

      final json = tarefa.toJson();

      expect(json['titulo'], equals('Testar Auth'));
      expect(json['descricao'], equals('Login por email e senha'));
      expect(json['concluida'], isFalse);
      expect(json['criadoEm'], isA<Timestamp>());
    });

    test('copyWith deve atualizar apenas campos informados', () {
      final tarefa = TarefaEstudo(
        id: 'doc_101',
        titulo: 'Titulo Original',
        descricao: 'Descricao Original',
        concluida: false,
      );

      final novaTarefa = tarefa.copyWith(
        titulo: 'Novo Titulo',
        concluida: true,
      );

      expect(novaTarefa.id, equals('doc_101'));
      expect(novaTarefa.titulo, equals('Novo Titulo'));
      expect(novaTarefa.descricao, equals('Descricao Original'));
      expect(novaTarefa.concluida, isTrue);
    });
  });
}
