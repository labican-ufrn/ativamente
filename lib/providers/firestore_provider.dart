import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercicio.dart';

final exerciciosProvider = StreamProvider<List<Exercicio>>((ref) {
  return FirebaseFirestore.instance.collection('Exercicios').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Exercicio.fromJson(doc.data(), doc.id)).toList();
  });
});

class _IntensidadeFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setIntensidade(int? value) {
    state = value;
  }
}

final intensidadeFilterProvider = NotifierProvider<_IntensidadeFilterNotifier, int?>(_IntensidadeFilterNotifier.new);

final exerciciosFiltradosProvider = Provider.family<AsyncValue<List<Exercicio>>, int?>((ref, filter) {
  final allExercicios = ref.watch(exerciciosProvider);
  return allExercicios.whenData((list) {
    if (filter == null) return list;
    final min = filter <= 5 ? 1 : filter <= 8 ? 6 : 9;
    final max = filter <= 5 ? 5 : filter <= 8 ? 8 : 10;
    return list.where((e) => e.intensidade >= min && e.intensidade <= max).toList();
  });
});
