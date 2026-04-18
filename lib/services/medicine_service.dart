import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineService {
  final _col = FirebaseFirestore.instance.collection('medicines');

  Stream<List<Medicine>> getMedicines() {
    return _col.snapshots().map((snap) =>
        snap.docs.map((d) => Medicine.fromMap(d.data())).toList());
  }

  Future<List<Medicine>> getMedicinesOnce() async {
    final snap = await _col.get();
    return snap.docs.map((d) => Medicine.fromMap(d.data())).toList();
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _col.doc(medicine.id).set(medicine.toMap());
  }

  Future<void> updateMedicine(Medicine medicine) async {
    try {
      await _col.doc(medicine.id).update(medicine.toMap());
      debugPrint('✅ Firestore update SUCCESS for ${medicine.name}');
    } catch (e) {
      debugPrint('❌ Firestore update FAILED: $e');
    }
  }

  // ✅ Directly deduct quantity using Firestore atomic increment
  Future<void> deductQuantity(String medicineId, int soldQty) async {
    try {
      debugPrint('⚡ Deducting $soldQty from medicine: $medicineId');
      await _col.doc(medicineId).update({
        'quantity': FieldValue.increment(-soldQty),
      });
      debugPrint('✅ Deduction SUCCESS for $medicineId');
    } catch (e) {
      debugPrint('❌ Deduction FAILED: $e');
    }
  }

  Future<void> deleteMedicine(String id) async {
    await _col.doc(id).delete();
  }
}