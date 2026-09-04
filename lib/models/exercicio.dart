class Categoria {
  final String nome;
  final String icone;

  Categoria({required this.nome, required this.icone});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      nome: json['nome'] ?? '',
      icone: json['icone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'icone': icone,
    };
  }
}

class Tipo {
  final String nome;
  final String icone;

  Tipo({required this.nome, required this.icone});

  factory Tipo.fromJson(Map<String, dynamic> json) {
    return Tipo(
      nome: json['nome'] ?? '',
      icone: json['icone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'icone': icone,
    };
  }
}

class Exercicio {
  final String id;
  final String codigo;
  final String nome;
  final String descricao;
  final String midia;
  final bool statusRealizado;
  final Categoria categoria;
  final Tipo tipo;

  Exercicio({
    required this.id,
    this.codigo = '',
    required this.nome,
    required this.descricao,
    required this.midia,
    this.statusRealizado = false,
    required this.categoria,
    required this.tipo,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json, String documentId) {
    final effectiveId = documentId.isNotEmpty ? documentId : (json['codigo'] ?? '');
    return Exercicio(
      id: effectiveId,
      codigo: json['codigo'] ?? effectiveId,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      midia: json['midia'] ?? '',
      statusRealizado: json['statusRealizado'] ?? false,
      categoria: Categoria.fromJson(json['categoria'] ?? {}),
      tipo: Tipo.fromJson(json['tipo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (codigo.isNotEmpty) 'codigo': codigo,
      'nome': nome,
      'descricao': descricao,
      'midia': midia,
      'statusRealizado': statusRealizado,
      'categoria': categoria.toJson(),
      'tipo': tipo.toJson(),
    };
  }
}
