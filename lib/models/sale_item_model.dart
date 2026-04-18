import 'medicine_model.dart';

class SaleItem {
  final Medicine medicine;
  final int quantity;
  final double itemTotal;

  SaleItem({
    required this.medicine,
    required this.quantity,
    required this.itemTotal,
  });

  double get total => itemTotal;

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicine.id,
      'medicineName': medicine.name,
      'price': medicine.price,
      'quantity': quantity,
      'total': itemTotal,
    };
  }
}