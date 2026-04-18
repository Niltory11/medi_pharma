import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../services/sales_service.dart';
import 'package:uuid/uuid.dart';

class SalesProvider extends ChangeNotifier {
  final _service = SalesService();
  final List<SaleItem> _cart = [];
  List<Sale> _sales = [];
  bool _isListening = false;

  List<SaleItem> get cart => _cart;
  List<Sale> get sales => _sales;
  double get cartTotal => _cart.fold(0, (s, i) => s + i.total);

  void listenToSales() {
    // ✅ Prevent duplicate listeners
    if (_isListening) return;
    _isListening = true;

    _service.getSales().listen((list) {
      _sales = list;
      debugPrint('🔥 Sales stream updated: ${list.length} sales');
      for (final s in list) {
        debugPrint('  💰 Sale: ${s.id} | Total: ${s.grandTotal} | Date: ${s.date}');
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ Sales stream error: $e');
    });
  }

  void addToCart(Medicine medicine, int qty) {
    final idx = _cart.indexWhere((i) => i.medicine.id == medicine.id);
    if (idx != -1) {
      final existing = _cart[idx];
      _cart[idx] = SaleItem(
        medicine: existing.medicine,
        quantity: existing.quantity + qty,
        itemTotal: existing.medicine.price * (existing.quantity + qty),
      );
    } else {
      _cart.add(SaleItem(
        medicine: medicine,
        quantity: qty,
        itemTotal: medicine.price * qty,
      ));
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

    final cartSnapshot = List<SaleItem>.from(_cart);
    final total = cartSnapshot.fold<double>(0, (s, i) => s + i.total);

    debugPrint('💰 Checkout total: $total');

    final sale = Sale(
      id: const Uuid().v4(),
      items: cartSnapshot,
      date: DateTime.now(),
      soldBy: soldBy,
      storedTotal: total,
    );

    await _service.addSale(sale);
    debugPrint('✅ Sale saved with total: $total');

    clearCart();
  }
}