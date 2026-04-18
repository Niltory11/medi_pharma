import 'sale_item_model.dart';

class Sale {
  final String id;
  final List<SaleItem> items;
  final DateTime date;
  final String soldBy;
  final double storedTotal;

  Sale({
    required this.id,
    required this.items,
    required this.date,
    required this.soldBy,
    required this.storedTotal,
  });

  double get grandTotal => storedTotal;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((e) => e.toMap()).toList(),
      'date': date.toIso8601String(),
      'soldBy': soldBy,
      'grandTotal': storedTotal,
    };
  }
}