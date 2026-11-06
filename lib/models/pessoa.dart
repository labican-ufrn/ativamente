class Notificacao {
  final String id;
  final String titulo;
  final String conteudo;
  final String data;
  final String hora;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.data,
    required this.hora,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['notificacao_id'] ?? '',
      titulo: json['titulo'] ?? '',
      conteudo: json['conteudo'] ?? '',
      data: json['data'] ?? '',
      hora: json['hora'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificacao_id': id,
      'titulo': titulo,
      'conteudo': conteudo,
      'data': data,
      'hora': hora,
    };
  }
}

class Pessoa {
  final String id;
  final String role; // 'admin', 'trainer', 'user'
  final String nome;
  final String email;
  final String foto;
  final String cpf;
  final String nomeLogin;
  final String numTelefone;
  final String dataNascimento;
  final double altura;
  final double peso;
  final String genero;
  final String cidade;
  final String comorbidade;
  final String freqAtivFisica;
  final String histEsportivo;
  final List<Notificacao> notificacoes;

  Pessoa({
    required this.id,
    this.role = 'user',
    required this.nome,
    this.email = '',
    this.foto = '',
    this.cpf = '',
    this.nomeLogin = '',
    this.numTelefone = '',
    this.dataNascimento = '',
    this.altura = 0.0,
    this.peso = 0.0,
    this.genero = '',
    this.cidade = '',
    this.comorbidade = '',
    this.freqAtivFisica = '',
    this.histEsportivo = '',
    this.notificacoes = const [],
  });

  factory Pessoa.fromJson(Map<String, dynamic> json, String documentId) {
    var notifsFromJson = json['notificacoes'] as List<dynamic>? ?? [];
    List<Notificacao> notifList = notifsFromJson
        .map((notifJson) => Notificacao.fromJson(notifJson as Map<String, dynamic>))
        .toList();

    return Pessoa(
      id: documentId,
      role: json['role'] ?? 'user',
      nome: json['nome'] ?? '',
      email: json['email'] ?? json['nomeLogin'] ?? '',
      foto: json['foto'] ?? '',
      cpf: json['cpf'] ?? '',
      nomeLogin: json['nomeLogin'] ?? json['email'] ?? '',
      numTelefone: json['numTelefone'] ?? '',
      dataNascimento: json['dataNascimento'] ?? '',
      altura: (json['altura'] ?? 0.0).toDouble(),
      peso: (json['peso'] ?? 0.0).toDouble(),
      genero: json['genero'] ?? '',
      cidade: json['cidade'] ?? '',
      comorbidade: json['comorbidade'] ?? '',
      freqAtivFisica: json['freqAtivFisica'] ?? '',
      histEsportivo: json['histEsportivo'] ?? '',
      notificacoes: notifList,
    );
  }

  Map<String, dynamic> toJson() {
    final effectiveEmail = email.isNotEmpty ? email : nomeLogin;
    final effectiveLogin = nomeLogin.isNotEmpty ? nomeLogin : email;
    return {
      'role': role,
      'nome': nome,
      'email': effectiveEmail,
      'foto': foto,
      'cpf': cpf,
      'nomeLogin': effectiveLogin,
      'numTelefone': numTelefone,
      'dataNascimento': dataNascimento,
      'altura': altura,
      'peso': peso,
      'genero': genero,
      'cidade': cidade,
      'comorbidade': comorbidade,
      'freqAtivFisica': freqAtivFisica,
      'histEsportivo': histEsportivo,
      'notificacoes': notificacoes.map((n) => n.toJson()).toList(),
    };
  }
}
