import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                        '৳${item.medicine.price.toStringAsFixed(2)} × ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '৳${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppColors.danger),
                          onPressed: () => cart
                              .removeFromCart(item.medicine.id),
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
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(
                        '৳${cart.cartTotal.toStringAsFixed(2)}',
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
                    final items = List.from(cart.cart);
                    final total = cart.cartTotal;
                    await cart.checkout(user?.username ?? 'staff');
                    if (context.mounted) {
                      await PdfUtils.generateReceipt(
                          items, total, user?.username ?? 'staff');
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