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
                    // ✅ Freeze ALL data into local variables first
                    // before ANY async operation or cart modification
                    final frozenIds = cart.cart
                        .map((i) => i.medicine.id)
                        .toList();
                    final frozenQtys = cart.cart
                        .map((i) => i.quantity)
                        .toList();
                    final frozenNames = cart.cart
                        .map((i) => i.medicine.name)
                        .toList();
                    final frozenPrices = cart.cart
                        .map((i) => i.medicine.price)
                        .toList();
                    final frozenTotals = cart.cart
                        .map((i) => i.total)
                        .toList();
                    final total = cart.cartTotal;
                    final soldBy = user?.username ?? 'staff';

                    debugPrint('🛒 Frozen ${frozenIds.length} items, Total: $total');

                    // ✅ Step 1 — Save sale to Firestore
                    await cart.checkout(soldBy);
                    debugPrint('✅ Sale saved');

                    // ✅ Step 2 — Deduct inventory using frozen data
                    final firestore = FirebaseFirestore.instance;
                    for (int i = 0; i < frozenIds.length; i++) {
                      debugPrint('⚡ Deducting ${frozenQtys[i]} from ${frozenNames[i]}');
                      try {
                        await firestore
                            .collection('medicines')
                            .doc(frozenIds[i])
                            .update({
                          'quantity': FieldValue.increment(-frozenQtys[i]),
                        });
                        debugPrint('✅ Done: ${frozenNames[i]}');
                      } catch (e) {
                        debugPrint('❌ Failed: ${frozenNames[i]}: $e');
                      }
                    }

                    // ✅ Step 3 — Build PDF snapshot from frozen data
                    final pdfSnapshot = List.generate(
                      frozenIds.length,
                          (i) => {
                        'id': frozenIds[i],
                        'name': frozenNames[i],
                        'price': frozenPrices[i],
                        'quantity': frozenQtys[i],
                        'total': frozenTotals[i],
                      },
                    );

                    // ✅ Step 4 — Generate PDF & go back
                    if (context.mounted) {
                      await PdfUtils.generateReceipt(
                          pdfSnapshot, total, soldBy);
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