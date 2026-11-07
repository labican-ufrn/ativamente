import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/models/pessoa.dart';

void main() {
  group('Notificacao', () {
    test('fromJson lê a chave notificacao_id e toJson a preserva', () {
      final json = {
        'notificacao_id': 'n1',
        'titulo': 'Hora do treino',
        'conteudo': 'Vamos caminhar?',
        'data': '07/11/2026',
        'hora': '08:00',
      };

      final notificacao = Notificacao.fromJson(json);

      expect(notificacao.id, 'n1');
      expect(notificacao.titulo, 'Hora do treino');
      expect(notificacao.conteudo, 'Vamos caminhar?');
      expect(notificacao.data, '07/11/2026');
      expect(notificacao.hora, '08:00');
      expect(notificacao.toJson(), json);
    });

    test('fromJson usa string vazia para campos ausentes', () {
      final notificacao = Notificacao.fromJson({});

      expect(notificacao.id, '');
      expect(notificacao.titulo, '');
      expect(notificacao.conteudo, '');
      expect(notificacao.data, '');
      expect(notificacao.hora, '');
    });
  });

  group('Pessoa', () {
    test('construtor aplica valores padrão (role user, sem notificações)', () {
      final pessoa = Pessoa(id: 'p1', nome: 'Maria');

      expect(pessoa.role, 'user');
      expect(pessoa.cpf, '');
      expect(pessoa.altura, 0.0);
      expect(pessoa.peso, 0.0);
      expect(pessoa.notificacoes, isEmpty);
    });

    test('fromJson lê todos os campos e usa o id do documento', () {
      final pessoa = Pessoa.fromJson({
        'role': 'trainer',
        'nome': 'João',
        'cpf': '123',
        'nomeLogin': 'joao@ativamente.org',
        'numTelefone': '(84) 99999-9999',
        'dataNascimento': '25/12/1950',
        'altura': 1.70,
        'peso': 72.5,
        'genero': 'M',
        'cidade': 'Natal',
        'comorbidade': 'Hipertensão',
        'freqAtivFisica': '3x semana',
        'histEsportivo': 'Natação',
        'notificacoes': [
          {'notificacao_id': 'n1', 'titulo': 'Oi'},
        ],
      }, 'doc-1');

      expect(pessoa.id, 'doc-1');
      expect(pessoa.role, 'trainer');
      expect(pessoa.nome, 'João');
      expect(pessoa.cpf, '123');
      expect(pessoa.nomeLogin, 'joao@ativamente.org');
      expect(pessoa.numTelefone, '(84) 99999-9999');
      expect(pessoa.dataNascimento, '25/12/1950');
      expect(pessoa.altura, 1.70);
      expect(pessoa.peso, 72.5);
      expect(pessoa.genero, 'M');
      expect(pessoa.cidade, 'Natal');
      expect(pessoa.comorbidade, 'Hipertensão');
      expect(pessoa.freqAtivFisica, '3x semana');
      expect(pessoa.histEsportivo, 'Natação');
      expect(pessoa.notificacoes, hasLength(1));
      expect(pessoa.notificacoes.single.id, 'n1');
      expect(pessoa.notificacoes.single.titulo, 'Oi');
    });

    test('fromJson converte números inteiros de altura/peso para double', () {
      final pessoa = Pessoa.fromJson({
        'nome': 'Ana',
        'altura': 2,
        'peso': 60,
      }, 'doc-2');

      expect(pessoa.altura, isA<double>());
      expect(pessoa.altura, 2.0);
      expect(pessoa.peso, 60.0);
    });

    test('fromJson com mapa vazio usa padrões seguros', () {
      final pessoa = Pessoa.fromJson({}, 'doc-3');

      expect(pessoa.id, 'doc-3');
      expect(pessoa.role, 'user');
      expect(pessoa.nome, '');
      expect(pessoa.altura, 0.0);
      expect(pessoa.notificacoes, isEmpty);
    });

    test('toJson não inclui o id e serializa as notificações', () {
      final pessoa = Pessoa(
        id: 'p1',
        nome: 'Maria',
        role: 'admin',
        peso: 65.0,
        notificacoes: [
          Notificacao(
            id: 'n1',
            titulo: 'T',
            conteudo: 'C',
            data: 'D',
            hora: 'H',
          ),
        ],
      );

      final json = pessoa.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['role'], 'admin');
      expect(json['nome'], 'Maria');
      expect(json['peso'], 65.0);
      expect(json['notificacoes'], [
        {
          'notificacao_id': 'n1',
          'titulo': 'T',
          'conteudo': 'C',
          'data': 'D',
          'hora': 'H',
        },
      ]);
    });

    test('toJson seguido de fromJson preserva os dados', () {
      final original = Pessoa(
        id: 'p1',
        nome: 'Maria',
        cidade: 'Natal',
        altura: 1.6,
        peso: 58.0,
      );

      final copia = Pessoa.fromJson(original.toJson(), original.id);

      expect(copia.toJson(), original.toJson());
      expect(copia.id, original.id);
    });
  });
}
