import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../services/sales_service.dart';
import '../services/medicine_service.dart';
import 'package:uuid/uuid.dart';

class SalesProvider extends ChangeNotifier {
  final _service = SalesService();
  final _medicineService = MedicineService();
  final List<SaleItem> _cart = [];
  List<Sale> _sales = [];

  List<SaleItem> get cart => _cart;
  List<Sale> get sales => _sales;
  double get cartTotal => _cart.fold(0, (s, i) => s + i.total);

  void listenToSales() {
    _service.getSales().listen((list) {
      _sales = list;
      notifyListeners();
    });
  }

  void addToCart(Medicine medicine, int qty) {
    final idx = _cart.indexWhere((i) => i.medicine.id == medicine.id);
    if (idx != -1) {
      _cart[idx].quantity += qty;
    } else {
      _cart.add(SaleItem(medicine: medicine, quantity: qty));
    }
    notifyListeners();
  }

  void removeFromCart(String medicineId) {
    _cart.removeWhere((i) => i.medicine.id == medicineId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<void> checkout(String soldBy) async {
    if (_cart.isEmpty) return;

    final sale = Sale(
      id: const Uuid().v4(),
      items: List.from(_cart),
      date: DateTime.now(),
      soldBy: soldBy,
    );

    // Save sale to Firestore
    await _service.addSale(sale);

    // ✅ Deduct quantity from each medicine in Firestore
    for (final item in _cart) {
      final updatedMedicine = item.medicine.copyWith(
        quantity: item.medicine.quantity - item.quantity,
      );
      await _medicineService.updateMedicine(updatedMedicine);
    }

    clearCart();
  }
}