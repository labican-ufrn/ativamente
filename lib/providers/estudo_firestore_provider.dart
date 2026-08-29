import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarefa_estudo.dart';

class EstudoFirestoreService {
  final FirebaseFirestore _firestore;

  EstudoFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('estudo_tarefas');

  /// Create: Adicionar documento
  Future<String> addTarefa(String titulo, String descricao) async {
    final docRef = await _collection.add({
      'titulo': titulo,
      'descricao': descricao,
      'concluida': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Read Stream: Leitura em tempo real
  Stream<List<TarefaEstudo>> getTarefasStream() {
    return _collection
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TarefaEstudo.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Read Pontual: Leitura única (consulta pontual via get)
  Future<List<TarefaEstudo>> fetchTarefasPontual() async {
    final snapshot = await _collection.orderBy('criadoEm', descending: true).get();
    return snapshot.docs
        .map((doc) => TarefaEstudo.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Update: Editar campos de um documento
  Future<void> updateTarefa(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  /// Delete: Remover documento
  Future<void> deleteTarefa(String id) async {
    await _collection.doc(id).delete();
  }
}

final estudoFirestoreServiceProvider = Provider<EstudoFirestoreService>((ref) {
  return EstudoFirestoreService();
});

final tarefasStreamProvider = StreamProvider<List<TarefaEstudo>>((ref) {
  final service = ref.watch(estudoFirestoreServiceProvider);
  return service.getTarefasStream();
});

final tarefasPontualProvider = FutureProvider<List<TarefaEstudo>>((ref) async {
  final service = ref.watch(estudoFirestoreServiceProvider);
  return service.fetchTarefasPontual();
});
