class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;

  const Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.concluida,
  });

  factory Tarefa.fromJson(Map<String, dynamic> json, String documentId) {
    return Tarefa(
      id: documentId,
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      concluida: json['concluida'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
    };
  }
}
