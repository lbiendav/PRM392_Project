import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import 'checkout_data.dart';
import 'checkout_screen.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  Future<void> _reorder(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại đơn này?'),
        content: const Text(
          'Các món của đơn cũ sẽ được thêm vào giỏ hiện tại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thêm vào giỏ'),
          ),
        ],
      ),
    );
    if (!context.mounted ||
        confirmed != true ||
        ref.read(checkoutUserIdProvider) != order.userId) {
      return;
    }
    final cart = ref.read(cartProvider.notifier);
    for (final item in order.items) {
      cart.addItem(item);
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(checkoutUserIdProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử đơn hàng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đang xử lý'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: uid == null
            ? const Center(child: Text('Vui lòng đăng nhập để xem đơn hàng.'))
            : ref
                  .watch(checkoutOrdersProvider(uid))
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(
                      child: TextButton(
                        onPressed: () =>
                            ref.invalidate(checkoutOrdersProvider(uid)),
                        child: const Text('Không tải được lịch sử. Thử lại'),
                      ),
                    ),
                    data: (orders) {
                      final groups = <List<OrderModel>>[[], [], []];
                      for (final order in orders) {
                        final index = switch (order.status) {
                          'completed' => 1,
                          'cancelled' => 2,
                          _ => 0,
                        };
                        groups[index].add(order);
                      }
                      return TabBarView(
                        children: [
                          for (final group in groups)
                            if (group.isEmpty)
                              const Center(
                                child: Text('Chưa có đơn hàng trong mục này.'),
                              )
                            else
                              ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: group.length,
                                itemBuilder: (context, index) {
                                  final order = group[index];
                                  return Card(
                                    child: ExpansionTile(
                                      title: Text('Đơn #${order.id}'),
                                      subtitle: Text(
                                        [
                                              AppFormatters.formatDateTime(
                                                order.createdAt,
                                              ),
                                              AppFormatters.formatCurrency(
                                                order.totalAmount,
                                              ),
                                            ]
                                            .where((value) => value.isNotEmpty)
                                            .join(' · '),
                                      ),
                                      children: [
                                        for (final item in order.items)
                                          ListTile(
                                            title: Text(item.productName),
                                            subtitle: Text(
                                              [
                                                'Size ${item.size} × ${item.quantity}',
                                                if (item.toppings.isNotEmpty)
                                                  item.toppings.join(', '),
                                                if (item.note.isNotEmpty)
                                                  item.note,
                                              ].join('\n'),
                                            ),
                                            trailing: Text(
                                              AppFormatters.formatCurrency(
                                                item.price * item.quantity,
                                              ),
                                            ),
                                          ),
                                        OverflowBar(
                                          alignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute<void>(
                                                      builder: (_) =>
                                                          OrderTrackingScreen(
                                                            orderId: order.id,
                                                          ),
                                                    ),
                                                  ),
                                              child: const Text(
                                                'Xem tiến trình',
                                              ),
                                            ),
                                            if (order.items.isNotEmpty)
                                              TextButton(
                                                onPressed: () => _reorder(
                                                  context,
                                                  ref,
                                                  order,
                                                ),
                                                child: const Text(
                                                  'Đặt lại đơn này',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}
