import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_service.dart';

class MedicineProvider extends ChangeNotifier {
  final _service = MedicineService();
  List<Medicine> _medicines = [];

  List<Medicine> get medicines => _medicines;
  List<Medicine> get lowStock => _medicines.where((m) => m.isLowStock).toList();
  List<Medicine> get nearExpiry => _medicines.where((m) => m.isNearExpiry).toList();
  List<Medicine> get expired => _medicines.where((m) => m.isExpired).toList();

  void listenToMedicines() {
    _service.getMedicines().listen((list) {
      _medicines = list;
      notifyListeners();
    });
  }

  Future<void> addMedicine(Medicine m) => _service.addMedicine(m);
  Future<void> updateMedicine(Medicine m) => _service.updateMedicine(m);
  Future<void> deleteMedicine(String id) => _service.deleteMedicine(id);

  List<Medicine> search(String query) {
    return _medicines
        .where((m) => m.name.toLowerCase().contains(query.toLowerCase()) ||
        m.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}