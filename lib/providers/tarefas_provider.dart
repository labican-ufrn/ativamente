import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tarefa.dart';

final tarefasCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instance.collection('tarefas'),
);

final tarefasProvider = StreamProvider<List<Tarefa>>((ref) {
  return ref.watch(tarefasCollectionProvider).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Tarefa.fromJson(doc.data(), doc.id))
            .toList(),
      );
});

final tarefasControllerProvider = Provider<TarefasController>((ref) {
  return TarefasController(ref.watch(tarefasCollectionProvider));
});

class TarefasController {
  final CollectionReference<Map<String, dynamic>> collection;

  const TarefasController(this.collection);

  Future<DocumentReference<Map<String, dynamic>>> criar({
    required String titulo,
    required String descricao,
  }) {
    return collection.add({
      'titulo': titulo,
      'descricao': descricao,
      'concluida': false,
      'criadaEm': FieldValue.serverTimestamp(),
    });
  }

  Future<Tarefa?> buscarPorId(String id) async {
    final snapshot = await collection.doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return Tarefa.fromJson(snapshot.data()!, snapshot.id);
  }

  Future<void> atualizar(Tarefa tarefa) {
    return collection.doc(tarefa.id).update(tarefa.toJson());
  }

  Future<void> remover(String id) {
    return collection.doc(id).delete();
  }
}
