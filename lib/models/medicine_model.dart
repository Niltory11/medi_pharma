class Medicine {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final DateTime expiryDate;
  final int lowStockThreshold;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.expiryDate,
    this.lowStockThreshold = 10,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isNearExpiry => !isExpired &&
      expiryDate.isBefore(DateTime.now().add(const Duration(days: 30)));
  bool get isLowStock => quantity <= lowStockThreshold;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'expiryDate': expiryDate.toIso8601String(),
      'lowStockThreshold': lowStockThreshold,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      expiryDate: DateTime.parse(map['expiryDate']),
      lowStockThreshold: map['lowStockThreshold'] ?? 10,
    );
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    double? price,
    DateTime? expiryDate,
    int? lowStockThreshold,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}