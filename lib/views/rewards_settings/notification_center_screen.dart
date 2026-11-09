import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final List<NotificationItemModel> _notifications = [
    NotificationItemModel(
      id: 'n1',
      userId: 'u1',
      title: '🛵 Đơn hàng của bạn đang được giao!',
      body: 'Tài xế Nguyễn Văn Hùng đang trên đường giao 2 ly Cà Phê Muối đến bạn.',
      type: 'order',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationItemModel(
      id: 'n2',
      userId: 'u1',
      title: '🎉 Khuyến mãi giờ vàng - Giảm 30%',
      body: 'Duy nhất hôm nay từ 14h - 17h, giảm ngay 30% khi đặt qua ứng dụng CoffeeCraft.',
      type: 'promo',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung Tâm Thông Báo'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var i = 0; i < _notifications.length; i++) {
                  _notifications[i] = _notifications[i].copyWith(isRead: true);
                }
              });
            },
            child: const Text('Đã đọc tất cả'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('Bạn chưa có thông báo nào.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: notif.isRead
                ? Theme.of(context).colorScheme.surface
                : AppColors.primary.withValues(alpha: 0.08),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notif.type == 'order' ? AppColors.primary : AppColors.secondary,
                child: Icon(
                  notif.type == 'order' ? Icons.local_shipping : Icons.local_offer,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(notif.body, style: const TextStyle(fontSize: 12)),
              trailing: notif.isRead
                  ? null
                  : const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}