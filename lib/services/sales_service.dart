import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../models/medicine_model.dart';

class SalesService {
  final _col = FirebaseFirestore.instance.collection('sales');

  Stream<List<Sale>> getSales() {
    return _col.snapshots().map((snap) {
      debugPrint('📥 Firestore sales snapshot: ${snap.docs.length} docs');
      final sales = snap.docs.map((d) => _saleFromMap(d.data())).toList();
      // Sort by date descending in memory
      sales.sort((a, b) => b.date.compareTo(a.date));
      return sales;
    });
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _col.doc(sale.id).set(sale.toMap());
      debugPrint('✅ Sale written to Firestore: ${sale.id}');
    } catch (e) {
      debugPrint('❌ Failed to write sale: $e');
    }
  }

  Sale _saleFromMap(Map<String, dynamic> map) {
    final items = (map['items'] as List).map((i) {
      final itemMap = i as Map<String, dynamic>;
      final medicine = Medicine(
        id: itemMap['medicineId'] ?? '',
        name: itemMap['medicineName'] ?? '',
        category: '',
        quantity: (itemMap['quantity'] as num?)?.toInt() ?? 0,
        price: (itemMap['price'] as num?)?.toDouble() ?? 0.0,
        expiryDate: DateTime.now(),
      );
      return SaleItem(
        medicine: medicine,
        quantity: (itemMap['quantity'] as num?)?.toInt() ?? 0,
        itemTotal: (itemMap['total'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    return Sale(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      soldBy: map['soldBy'] ?? '',
      items: items,
      storedTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}