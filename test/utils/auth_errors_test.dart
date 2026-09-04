import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_academia/utils/auth_errors.dart';

void main() {
  group('getFriendlyErrorMessage (Tradução de Erros de Autenticação)', () {
    test('deve traduzir erro de usuário não encontrado (user-not-found)', () {
      final error = FirebaseAuthException(code: 'user-not-found');
      expect(getFriendlyErrorMessage(error), equals('Usuário não encontrado. Verifique seu e-mail.'));
    });

    test('deve traduzir erro de usuário não encontrado (EMAIL_NOT_FOUND)', () {
      final error = FirebaseAuthException(code: 'EMAIL_NOT_FOUND');
      expect(getFriendlyErrorMessage(error), equals('Usuário não encontrado. Verifique seu e-mail.'));
    });

    test('deve traduzir erro de senha incorreta (wrong-password)', () {
      final error = FirebaseAuthException(code: 'wrong-password');
      expect(getFriendlyErrorMessage(error), equals('Senha incorreta. Tente novamente.'));
    });

    test('deve traduzir erro de senha incorreta (INVALID_LOGIN_CREDENTIALS)', () {
      final error = FirebaseAuthException(code: 'INVALID_LOGIN_CREDENTIALS');
      expect(getFriendlyErrorMessage(error), equals('Senha incorreta. Tente novamente.'));
    });

    test('deve traduzir credenciais inválidas (invalid-credential)', () {
      final error = FirebaseAuthException(code: 'invalid-credential');
      expect(getFriendlyErrorMessage(error), equals('E-mail ou senha inválidos.'));
    });

    test('deve traduzir e-mail em uso (email-already-in-use)', () {
      final error = FirebaseAuthException(code: 'email-already-in-use');
      expect(getFriendlyErrorMessage(error), equals('Este e-mail já está cadastrado.'));
    });

    test('deve traduzir senha fraca (weak-password)', () {
      final error = FirebaseAuthException(code: 'weak-password');
      expect(getFriendlyErrorMessage(error), equals('A senha deve ter pelo menos 6 caracteres.'));
    });

    test('deve traduzir excesso de requisições (too-many-requests)', () {
      final error = FirebaseAuthException(code: 'too-many-requests');
      expect(getFriendlyErrorMessage(error), equals('Muitas tentativas de acesso. Por favor, aguarde alguns minutos.'));
    });

    test('deve tratar falha de conexão de rede genérica', () {
      final error = Exception('network-request-failed');
      expect(getFriendlyErrorMessage(error), equals('Falha na conexão de rede. Verifique se está conectado à internet.'));
    });

    test('deve retornar mensagem padrão para exceções desconhecidas', () {
      final error = Exception('Some generic unknown error');
      expect(getFriendlyErrorMessage(error), equals('Não foi possível conectar. Verifique seus dados e tente novamente.'));
    });

    test('deve retornar a mensagem original do Firebase para código desconhecido', () {
      final error = FirebaseAuthException(code: 'codigo-desconhecido', message: 'Mensagem original de erro.');
      expect(getFriendlyErrorMessage(error), equals('Mensagem original de erro.'));
    });

    test('deve retornar mensagem padrão para código desconhecido se mensagem for nula', () {
      final error = FirebaseAuthException(code: 'codigo-desconhecido');
      expect(getFriendlyErrorMessage(error), equals('Erro na autenticação. Verifique os dados e tente novamente.'));
    });
  });
}
