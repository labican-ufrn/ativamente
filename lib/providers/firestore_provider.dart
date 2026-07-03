import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercicio.dart';

final exerciciosProvider = StreamProvider<List<Exercicio>>((ref) {
  return FirebaseFirestore.instance.collection('Exercicios').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Exercicio.fromJson(doc.data(), doc.id)).toList();
  });
});
