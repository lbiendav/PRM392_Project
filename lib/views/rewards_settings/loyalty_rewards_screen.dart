import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../providers/auth_provider.dart';

class LoyaltyRewardsScreen extends ConsumerWidget {
  const LoyaltyRewardsScreen({super.key});

  String _getTierName(int points) {
    if (points >= 500) return 'Kim Cương 💎';
    if (points >= 200) return 'Vàng 👑';
    if (points >= 100) return 'Bạc 🥈';
    return 'Đồng 🥉';
  }

  Color _getTierColor(int points) {
    if (points >= 500) return const Color(0xFF0077B6);
    if (points >= 200) return const Color(0xFFD4AF37);
    if (points >= 100) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).userModel;
    final points = user?.loyaltyPoints ?? 50;
    final tierName = _getTierName(points);
    final tierColor = _getTierColor(points);
    const int nextMilestone = 100;
    final progress = (points / nextMilestone).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Thẻ Thành Viên & Điểm Thưởng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Thẻ ảo VIP
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tierColor, tierColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CoffeeCraft Member',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        tierName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    user?.fullName ?? 'Khách Hàng Thân Thiết',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Điểm hiện tại: $points xu',
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const Icon(Icons.coffee, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tiến độ nâng hạng
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiến trình lên hạng Bạc', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$points / $nextMilestone điểm', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.primary,
                      backgroundColor: AppColors.borderLight,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tích thêm ${nextMilestone - points} điểm để nhận thêm nhiều quyền lợi giảm giá 10%!',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Danh sách quà đổi điểm
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Đổi Quà Thưởng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildRewardItem(
              context,
              'Voucher Giảm 20.000đ',
              'Đổi với 30 điểm',
              30,
              points,
            ),
            _buildRewardItem(
              context,
              'Tặng 01 Bánh Croissant bơ',
              'Đổi với 50 điểm',
              50,
              points,
            ),
            _buildRewardItem(
              context,
              'Tặng 01 Ly Cà phê sữa đá size M',
              'Đổi với 60 điểm',
              60,
              points,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(
      BuildContext context,
      String title,
      String subtitle,
      int cost,
      int userPoints,
      ) {
    final canRedeem = userPoints >= cost;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, 36),
            backgroundColor: canRedeem ? AppColors.primary : Colors.grey,
          ),
          onPressed: canRedeem
              ? () {
            SnackBarUtils.showSuccess(context, 'Đổi quà thành công!');
          }
              : null,
          child: const Text('Đổi'),
        ),
      ),
    );
  }
}