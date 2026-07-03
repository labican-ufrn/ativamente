class TreinoSugerido {
  final String id;
  final String titulo;
  final int numRepeticao;
  final int numSerie;
  final String tempoMedio;
  final String dificuldade;
  final List<String> exerciciosIds;

  TreinoSugerido({
    required this.id,
    required this.titulo,
    this.numRepeticao = 0,
    this.numSerie = 0,
    this.tempoMedio = '',
    this.dificuldade = '',
    this.exerciciosIds = const [],
  });

  factory TreinoSugerido.fromJson(Map<String, dynamic> json, String documentId) {
    return TreinoSugerido(
      id: documentId,
      titulo: json['titulo'] ?? '',
      numRepeticao: json['numRepeticao'] ?? 0,
      numSerie: json['numSerie'] ?? 0,
      tempoMedio: json['tempoMedio'] ?? '',
      dificuldade: json['dificuldade'] ?? '',
      exerciciosIds: List<String>.from(json['exercicios_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'numRepeticao': numRepeticao,
      'numSerie': numSerie,
      'tempoMedio': tempoMedio,
      'dificuldade': dificuldade,
      'exercicios_ids': exerciciosIds,
    };
  }
}
