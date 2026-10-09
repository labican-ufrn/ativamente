import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_academia/models/pessoa.dart';
import 'package:app_academia/providers/auth_provider.dart';

class FakeUser extends Fake implements User {
  @override
  final String? displayName;

  @override
  final String? email;

  FakeUser({this.displayName, this.email});
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
}
