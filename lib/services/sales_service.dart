import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../models/medicine_model.dart';

class SalesService {
  final _col = FirebaseFirestore.instance.collection('sales');

  Stream<List<Sale>> getSales() {
    return _col.orderBy('date', descending: true).snapshots().map(
          (snap) =>
          snap.docs.map((d) => _saleFromMap(d.data())).toList(),
    );
  }

  Future<void> addSale(Sale sale) async {
    await _col.doc(sale.id).set(sale.toMap());
  }

  Sale _saleFromMap(Map<String, dynamic> map) {
    final items = (map['items'] as List).map((i) {
      final itemMap = i as Map<String, dynamic>;
      final medicine = Medicine(
        id: itemMap['medicineId'],
        name: itemMap['medicineName'],
        category: '',
        quantity: 0,
        price: (itemMap['price'] as num).toDouble(),
        expiryDate: DateTime.now(),
      );
      return SaleItem(
        medicine: medicine,
        quantity: itemMap['quantity'] as int,
      );
    }).toList();

    return Sale(
      id: map['id'],
      date: DateTime.parse(map['date']),
      soldBy: map['soldBy'],
      items: items,
    );
  }
}