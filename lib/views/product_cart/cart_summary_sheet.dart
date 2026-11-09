import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../checkout_order/checkout_screen.dart';
import 'cart_screen.dart';

class CartSummarySheet extends ConsumerWidget {
  const CartSummarySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giỏ hàng (${cart.totalItemCount})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (cart.items.isNotEmpty)
                Text(
                  AppFormatters.formatCurrency(cart.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (cart.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Giỏ hàng của bạn đang trống.')),
            ),
          ...cart.items.map((item) {
            final options = [
              if (item.sugarPercent != null) 'Đường ${item.sugarPercent}%',
              if (item.iceLevel == 'less') 'Ít đá',
              if (item.iceLevel == 'none') 'Không đá',
              if (item.iceLevel == 'normal') 'Đá bình thường',
              if (item.toppings.isNotEmpty)
                'Topping: ${item.toppings.join(', ')}',
            ];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.productName),
              subtitle: Text(
                '${item.quantity} × ${item.size}'
                '${options.isEmpty ? '' : ' • ${options.join(' • ')}'}',
              ),
              trailing: Text(
                AppFormatters.formatCurrency(item.price * item.quantity),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                  child: const Text('Xem giỏ hàng'),
                ),
              ),
              if (cart.items.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: const Text('Đặt hàng ngay'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
