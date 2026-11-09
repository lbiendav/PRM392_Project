import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const double shippingFee = 15000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Giỏ hàng')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64),
              const SizedBox(height: 12),
              const Text('Giỏ hàng đang trống'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Quay lại menu'),
              ),
            ],
          ),
        ),
      );
    }

    final total = cart.subtotal + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng (${cart.totalItemCount})'),
        actions: [
          IconButton(
            tooltip: 'Xóa toàn bộ giỏ hàng',
            onPressed: () {
              notifier.clearCart();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];

          return Dismissible(
            key: ValueKey('${item.productId}-$index'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => notifier.removeItem(index),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imageUrl.isEmpty
                          ? const SizedBox(
                              width: 70,
                              height: 70,
                              child: ColoredBox(
                                color: Colors.black12,
                                child: Icon(Icons.local_cafe),
                              ),
                            )
                          : Image.network(
                              item.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 70,
                                height: 70,
                                child: ColoredBox(
                                  color: Colors.black12,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Size ${item.size}'),
                          if (item.toppings.isNotEmpty)
                            Text(
                              item.toppings.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters.formatCurrency(item.price),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          tooltip: 'Tăng số lượng',
                          onPressed: () {
                            notifier.updateQuantity(index, item.quantity + 1);
                          },
                          icon: const Icon(Icons.add),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          tooltip: 'Giảm số lượng',
                          onPressed: () {
                            notifier.updateQuantity(index, item.quantity - 1);
                          },
                          icon: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TotalRow(label: 'Tạm tính', value: cart.subtotal),
            _TotalRow(label: 'Phí giao hàng', value: shippingFee),
            const Divider(),
            _TotalRow(label: 'Tổng cộng', value: total, emphasized: true),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chức năng đặt hàng sẽ nối với Member 4'),
                    ),
                  );
                },
                child: const Text('Tiến hành đặt hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasized;

  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(AppFormatters.formatCurrency(value), style: style),
        ],
      ),
    );
  }
}
