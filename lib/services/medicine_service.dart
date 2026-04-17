import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineService {
  final _col = FirebaseFirestore.instance.collection('medicines');

  Stream<List<Medicine>> getMedicines() {
    return _col.snapshots().map((snap) =>
        snap.docs.map((d) => Medicine.fromMap(d.data())).toList());
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _col.doc(medicine.id).set(medicine.toMap());
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _col.doc(medicine.id).update(medicine.toMap());
  }

  Future<void> deleteMedicine(String id) async {
    await _col.doc(id).delete();
  }
}