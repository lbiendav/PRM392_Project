import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../models/voucher_model.dart';

List<VoucherModel> buildDefaultWalletVouchers() {
  final now = DateTime.now();
  return [
    VoucherModel(
      id: 'v1',
      code: 'FREESHIP18K',
      title: 'Miễn Phí Giao Hàng Toàn Quốc',
      description: 'Giảm tối đa 18.000đ phí giao hàng cho đơn từ 50.000đ',
      discountType: 'freeship',
      discountValue: 18000,
      minOrderAmount: 50000,
      expiryDate: now.add(const Duration(days: 7)),
    ),
    VoucherModel(
      id: 'v2',
      code: 'COFFEELOVERS',
      title: 'Giảm 20% Toàn Bộ Menu Cà Phê',
      description: 'Áp dụng cho tất cả đồ uống Cà Phê truyền thống và pha máy',
      discountType: 'percentage',
      discountValue: 20,
      minOrderAmount: 40000,
      maxDiscount: 30000,
      expiryDate: now.add(const Duration(days: 14)),
    ),
    VoucherModel(
      id: 'v3',
      code: 'WELCOME50K',
      title: 'Giảm 50.000đ Chào Mừng Bạn Mới',
      description: 'Dành riêng cho đơn hàng đầu tiên từ 100.000đ',
      discountType: 'fixed',
      discountValue: 50000,
      minOrderAmount: 100000,
      expiryDate: now.add(const Duration(days: 30)),
    ),
    VoucherModel(
      id: 'v4',
      code: 'REWARD20K',
      title: 'Voucher Đổi Điểm Giảm 20.000đ',
      description: 'Ưu đãi dành cho thành viên đổi điểm thưởng CoffeeCraft',
      discountType: 'fixed',
      discountValue: 20000,
      minOrderAmount: 40000,
      expiryDate: now.add(const Duration(days: 30)),
    ),
  ];
}

class VoucherWalletScreen extends StatefulWidget {
  final bool isSelectMode;
  const VoucherWalletScreen({super.key, this.isSelectMode = false});

  @override
  State<VoucherWalletScreen> createState() => _VoucherWalletScreenState();
}

class _VoucherWalletScreenState extends State<VoucherWalletScreen> {
  late final List<VoucherModel> _vouchers = buildDefaultWalletVouchers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ví Khuyến Mãi (Vouchers)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vouchers.length,
        itemBuilder: (context, index) {
          final v = _vouchers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      v.discountType == 'freeship'
                          ? Icons.local_shipping_rounded
                          : Icons.confirmation_number_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          v.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                v.code,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'HSD: ${AppFormatters.formatDate(v.expiryDate)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(64, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: v.code));
                      SnackBarUtils.showSuccess(
                        context,
                        'Đã sao chép mã ${v.code}!',
                      );
                      if (widget.isSelectMode) {
                        Navigator.of(context).pop(v);
                      }
                    },
                    child: Text(widget.isSelectMode ? 'Chọn' : 'Dùng'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
