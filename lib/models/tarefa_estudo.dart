import 'package:cloud_firestore/cloud_firestore.dart';

class TarefaEstudo {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final DateTime? criadoEm;

  TarefaEstudo({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
    this.criadoEm,
  });

  factory TarefaEstudo.fromJson(Map<String, dynamic> json, String documentId) {
    DateTime? dataCriacao;
    final rawData = json['criadoEm'];
    if (rawData is Timestamp) {
      dataCriacao = rawData.toDate();
    } else if (rawData is String) {
      dataCriacao = DateTime.tryParse(rawData);
    }

    return TarefaEstudo(
      id: documentId,
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      concluida: json['concluida'] ?? false,
      criadoEm: dataCriacao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
      'criadoEm': criadoEm != null ? Timestamp.fromDate(criadoEm!) : FieldValue.serverTimestamp(),
    };
  }

  TarefaEstudo copyWith({
    String? id,
    String? titulo,
    String? descricao,
    bool? concluida,
    DateTime? criadoEm,
  }) {
    return TarefaEstudo(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
