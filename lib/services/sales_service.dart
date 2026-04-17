import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';

class SalesService {
  final _col = FirebaseFirestore.instance.collection('sales');

  Stream<List<Sale>> getSales() {
    return _col.orderBy('date', descending: true).snapshots().map((snap) =>
        snap.docs.map((d) => _saleFromMap(d.data())).toList());
  }

  Future<void> addSale(Sale sale) async {
    await _col.doc(sale.id).set(sale.toMap());
  }

  Sale _saleFromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      date: DateTime.parse(map['date']),
      soldBy: map['soldBy'],
      items: (map['items'] as List).map((i) => _saleItemFromMap(i)).toList(),
    );
  }

  // ignore: unused_element
  _saleItemFromMap(Map<String, dynamic> map) {
    // lightweight reconstruction for history display
    return _MinimalSaleItem(map);
  }
}

class _MinimalSaleItem {
  final Map<String, dynamic> data;
  _MinimalSaleItem(this.data);
}