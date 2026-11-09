import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../checkout_order/address_management_screen.dart';
import '../checkout_order/order_history_screen.dart';
import '../product_cart/favorites_screen.dart';
import '../rewards_settings/help_and_faq_screen.dart';
import '../rewards_settings/loyalty_rewards_screen.dart';
import '../rewards_settings/notification_center_screen.dart';
import '../rewards_settings/settings_screen.dart';
import '../rewards_settings/voucher_wallet_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.userModel;
    final firebaseUser = authState.firebaseUser;

    final nameController = TextEditingController(
      text: user?.fullName ?? firebaseUser?.displayName ?? '',
    );
    final phoneController = TextEditingController(
      text: user?.phoneNumber ?? firebaseUser?.phoneNumber ?? '',
    );
    final dobController = TextEditingController(text: user?.dateOfBirth ?? '');
    final formKey = GlobalKey<FormState>();
    File? selectedAvatar;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cập nhật hồ sơ'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedAvatar = File(picked.path);
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          backgroundImage: selectedAvatar != null
                              ? FileImage(selectedAvatar!)
                              : (user?.photoUrl != null &&
                                        user!.photoUrl!.isNotEmpty
                                    ? NetworkImage(user.photoUrl!)
                                          as ImageProvider
                                    : null),
                          child:
                              selectedAvatar == null &&
                                  (user?.photoUrl == null ||
                                      user!.photoUrl!.isEmpty)
                              ? const Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chạm để đổi ảnh đại diện',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: AppValidators.validateFullName,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: AppValidators.validatePhoneNumber,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh (DD/MM/YYYY)',
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop();
                    final ok = await ref
                        .read(authNotifierProvider.notifier)
                        .updateProfile(
                          fullName: nameController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                          dateOfBirth: dobController.text.trim().isEmpty
                              ? null
                              : dobController.text.trim(),
                          newAvatarFile: selectedAvatar,
                        );
                    if (!context.mounted) return;
                    if (ok) {
                      SnackBarUtils.showSuccess(
                        context,
                        'Đã cập nhật hồ sơ thành công!',
                      );
                    } else {
                      final err =
                          ref.read(authNotifierProvider).errorMessage ??
                          'Không thể cập nhật hồ sơ.';
                      SnackBarUtils.showError(context, err);
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.userModel;
    final firebaseUser = authState.firebaseUser;
    final favoritesCount = ref.watch(favoritesProvider).length;

    final displayName =
        user?.fullName ?? firebaseUser?.displayName ?? 'Khách hàng CoffeeCraft';
    final email = user?.email ?? firebaseUser?.email ?? '';
    final phone = user?.phoneNumber ?? firebaseUser?.phoneNumber ?? '';
    final photoUrl = user?.photoUrl ?? firebaseUser?.photoURL;
    final points = user?.loyaltyPoints ?? 50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        actions: [
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () => _open(context, const NotificationCenterScreen()),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Cài đặt',
            onPressed: () => _open(context, const SettingsScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '⭐ $points điểm thưởng',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chỉnh sửa hồ sơ',
                    onPressed: () => _showEditProfileDialog(context, ref),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuSection(
            title: 'Đơn hàng & Tiện ích',
            items: [
              _MenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Lịch sử đơn hàng',
                subtitle: 'Theo dõi đơn đang giao & đặt lại đơn cũ',
                onTap: () => _open(context, const OrderHistoryScreen()),
              ),
              _MenuItem(
                icon: Icons.favorite_border,
                title: 'Món yêu thích',
                subtitle: favoritesCount > 0
                    ? '$favoritesCount món đã lưu'
                    : 'Danh sách đồ uống yêu thích của bạn',
                onTap: () => _open(context, const FavoritesScreen()),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: 'Sổ địa chỉ nhận hàng',
                subtitle: 'Quản lý địa chỉ giao hàng mặc định',
                onTap: () => _open(context, const AddressManagementScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuSection(
            title: 'Thành viên & Ưu đãi',
            items: [
              _MenuItem(
                icon: Icons.workspace_premium_outlined,
                title: 'Thẻ thành viên & Điểm thưởng',
                subtitle: 'Hạng thẻ, tích điểm và đổi quà',
                onTap: () => _open(context, const LoyaltyRewardsScreen()),
              ),
              _MenuItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Ví khuyến mãi (Vouchers)',
                subtitle: 'Mã giảm giá và ưu đãi vận chuyển',
                onTap: () => _open(context, const VoucherWalletScreen()),
              ),
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: 'Trung tâm thông báo',
                subtitle: 'Cập nhật đơn hàng và tin khuyến mãi',
                onTap: () => _open(context, const NotificationCenterScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuSection(
            title: 'Hệ thống & Hỗ trợ',
            items: [
              _MenuItem(
                icon: Icons.settings_outlined,
                title: 'Cài đặt hệ thống',
                subtitle: 'Giao diện Sáng/Tối, thông báo, ngôn ngữ',
                onTap: () => _open(context, const SettingsScreen()),
              ),
              _MenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Trợ giúp & Góp ý (FAQ)',
                subtitle: 'Câu hỏi thường gặp và gửi phản hồi',
                onTap: () => _open(context, const HelpAndFAQScreen()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  leading: Icon(items[i].icon, color: AppColors.primary),
                  title: Text(items[i].title),
                  subtitle: Text(
                    items[i].subtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: items[i].onTap,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
