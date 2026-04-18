import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sales_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/utils/pdf_utils.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<SalesProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (cart.cart.isNotEmpty)
            TextButton(
              onPressed: () => cart.clearCart(),
              child: const Text('Clear',
                  style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: cart.cart.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: Colors.grey),
            SizedBox(height: 12),
            Text('Cart is empty',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.cart.length,
              itemBuilder: (_, i) {
                final item = cart.cart[i];
                return Card(
                  child: ListTile(
                    title: Text(item.medicine.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        'BDT ${item.medicine.price.toStringAsFixed(2)} x ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'BDT ${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppColors.danger),
                          onPressed: () =>
                              cart.removeFromCart(item.medicine.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Total & Checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 8)
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(
                        'BDT ${cart.cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Checkout & Print Receipt',
                  onPressed: () async {
                    // ✅ Step 1 — Deep snapshot as raw maps
                    // completely independent of cart state
                    final snapshot = cart.cart
                        .map((item) => {
                      'id': item.medicine.id,
                      'name': item.medicine.name,
                      'price': item.medicine.price,
                      'quantity': item.quantity,
                      'total': item.total,
                    })
                        .toList();

                    final total = cart.cartTotal;
                    final soldBy = user?.username ?? 'staff';

                    debugPrint(
                        '🛒 Snapshot: ${snapshot.length} items, Total: $total');

                    // ✅ Step 2 — Save sale to Firestore
                    await cart.checkout(soldBy);
                    debugPrint('✅ Sale saved');

                    // ✅ Step 3 — Deduct inventory using snapshot
                    final firestore = FirebaseFirestore.instance;
                    for (final item in snapshot) {
                      final medicineId = item['id'] as String;
                      final qty = item['quantity'] as int;
                      final name = item['name'] as String;
                      try {
                        await firestore
                            .collection('medicines')
                            .doc(medicineId)
                            .update({
                          'quantity': FieldValue.increment(-qty),
                        });
                        debugPrint('✅ Deducted $qty from $name');
                      } catch (e) {
                        debugPrint('❌ Failed to deduct $name: $e');
                      }
                    }

                    // ✅ Step 4 — Generate PDF receipt
                    if (context.mounted) {
                      await PdfUtils.generateReceipt(
                          snapshot, total, soldBy);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}