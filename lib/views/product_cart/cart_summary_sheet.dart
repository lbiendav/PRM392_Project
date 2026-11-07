import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';

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
          Text('Giỏ hàng (${cart.totalItemCount})'),
          ...cart.items.map(
            (item) => ListTile(
              title: Text(item.productName),
              subtitle: Text('${item.quantity} × ${item.size}'),
            ),
          ),
        ],
      ),
    );
  }
}
