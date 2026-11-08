import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'checkout_data.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});
  final String orderId;

  Future<void> _call(BuildContext context, String phone) async {
    try {
      if (await launchUrl(Uri(scheme: 'tel', path: phone))) return;
    } catch (_) {
      // The device may have no dialer.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng gọi điện.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theo dõi đơn hàng')),
      body: ref
          .watch(checkoutOrderProvider(orderId))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(checkoutOrderProvider(orderId)),
                child: const Text('Không tải được đơn hàng. Thử lại'),
              ),
            ),
            data: (details) {
              if (details == null) {
                return const Center(child: Text('Không tìm thấy đơn hàng.'));
              }
              final order = details.order;
              final pickup = order.deliveryType == 'pickup';
              final cancelled = order.status == 'cancelled';
              final completed = order.status == 'completed';
              final currentStep = switch (order.status) {
                'preparing' => 1,
                'delivering' || 'ready' => 2,
                'completed' => 3,
                _ => 0,
              };
              final labels = [
                'Đã tiếp nhận',
                'Đang pha chế',
                pickup ? 'Sẵn sàng nhận tại quán' : 'Đang giao hàng',
                'Hoàn tất',
              ];
              final phone = details.contactPhone?.trim();
              final photo = pickup ? null : details.driverPhotoUrl?.trim();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Mã đơn #${order.id}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (order.shippingAddress.isNotEmpty)
                    Text(order.shippingAddress),
                  if (cancelled)
                    const ListTile(
                      leading: Icon(Icons.cancel_outlined),
                      title: Text('Đơn hàng đã hủy'),
                    )
                  else
                    Stepper(
                      physics: const NeverScrollableScrollPhysics(),
                      currentStep: currentStep,
                      controlsBuilder: (_, _) => const SizedBox.shrink(),
                      steps: [
                        for (var i = 0; i < labels.length; i++)
                          Step(
                            title: Text(labels[i]),
                            content: const SizedBox.shrink(),
                            isActive: i <= currentStep,
                            state: completed || i < currentStep
                                ? StepState.complete
                                : StepState.indexed,
                          ),
                      ],
                    ),
                  if (!cancelled && !completed)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          foregroundImage: photo == null || photo.isEmpty
                              ? null
                              : NetworkImage(photo),
                          child: Icon(
                            pickup ? Icons.storefront : Icons.delivery_dining,
                          ),
                        ),
                        title: Text(
                          details.contactName ??
                              (pickup ? 'Cửa hàng' : 'Tài xế giao hàng'),
                        ),
                        subtitle: Text(
                          [
                            if (!pickup &&
                                details.driverPlate?.isNotEmpty == true)
                              details.driverPlate!,
                            phone == null || phone.isEmpty
                                ? 'Chưa có số liên hệ'
                                : phone,
                          ].join(' · '),
                        ),
                        trailing: phone == null || phone.isEmpty
                            ? null
                            : IconButton(
                                tooltip: pickup ? 'Gọi cửa hàng' : 'Gọi tài xế',
                                icon: const Icon(Icons.phone_outlined),
                                onPressed: () => _call(context, phone),
                              ),
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }
}
