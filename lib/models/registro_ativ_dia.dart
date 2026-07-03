class RegistroAtivDia {
  final String id;
  final String data;
  final String horaInicio;
  final String duracao;
  final String ownerPessoaId;
  final String ownerExercicioId;
  final String ownerTreinoSugeridoId;

  RegistroAtivDia({
    required this.id,
    required this.data,
    required this.horaInicio,
    required this.duracao,
    required this.ownerPessoaId,
    required this.ownerExercicioId,
    required this.ownerTreinoSugeridoId,
  });

  factory RegistroAtivDia.fromJson(Map<String, dynamic> json, String documentId) {
    return RegistroAtivDia(
      id: documentId,
      data: json['data'] ?? '',
      horaInicio: json['horaInicio'] ?? '',
      duracao: json['duracao'] ?? '',
      ownerPessoaId: json['ownerPessoa_id'] ?? '',
      ownerExercicioId: json['ownerExercicio_id'] ?? '',
      ownerTreinoSugeridoId: json['ownerTreinoSugerido_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'horaInicio': horaInicio,
      'duracao': duracao,
      'ownerPessoa_id': ownerPessoaId,
      'ownerExercicio_id': ownerExercicioId,
      'ownerTreinoSugerido_id': ownerTreinoSugeridoId,
    };
  }
}
