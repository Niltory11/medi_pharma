import 'medicine_model.dart';

class SaleItem {
  final Medicine medicine;
  int quantity;

  SaleItem({required this.medicine, required this.quantity});

  double get total => medicine.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicine.id,
      'medicineName': medicine.name,
      'price': medicine.price,
      'quantity': quantity,
      'total': total,
    };
  }
}