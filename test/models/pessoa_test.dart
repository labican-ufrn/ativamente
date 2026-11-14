import 'package:flutter_test/flutter_test.dart';
import 'package:app_academia/models/pessoa.dart';

void main() {
  test('trainer e admin podem gerenciar exercícios', () {
    for (final role in ['trainer', 'admin']) {
      final pessoa = Pessoa(id: 'pessoa-1', nome: 'Usuário Teste', role: role);

      expect(pessoa.podeGerenciarExercicios, isTrue);
    }
  });

  test('usuário comum não pode gerenciar exercícios', () {
    final pessoa = Pessoa(id: 'pessoa-1', nome: 'Usuário Teste');

    expect(pessoa.podeGerenciarExercicios, isFalse);
  });
}
