import 'package:firebase_auth/firebase_auth.dart';

/// Retorna uma mensagem de erro amigável em português (PT-BR) para idosos.
String getFriendlyErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
      case 'EMAIL_NOT_FOUND':
        return 'Usuário não encontrado. Verifique seu e-mail.';
      case 'wrong-password':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Senha incorreta. Tente novamente.';
      case 'invalid-credential':
      case 'invalid-email':
        return 'E-mail ou senha inválidos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas de acesso. Por favor, aguarde alguns minutos.';
      default:
        return error.message ?? 'Erro na autenticação. Verifique os dados e tente novamente.';
    }
  }

  final errorStr = error.toString().toLowerCase();
  if (errorStr.contains('user-not-found') || errorStr.contains('email_not_found')) {
    return 'Usuário não encontrado. Verifique seu e-mail.';
  }
  if (errorStr.contains('wrong-password') || errorStr.contains('invalid_login_credential')) {
    return 'Senha incorreta. Tente novamente.';
  }
  if (errorStr.contains('invalid-credential') || errorStr.contains('invalid-email')) {
    return 'E-mail ou senha inválidos.';
  }
  if (errorStr.contains('email-already-in-use')) {
    return 'Este e-mail já está cadastrado.';
  }
  if (errorStr.contains('network-request-failed')) {
    return 'Falha na conexão de rede. Verifique se está conectado à internet.';
  }

  return 'Não foi possível conectar. Verifique seus dados e tente novamente.';
}
