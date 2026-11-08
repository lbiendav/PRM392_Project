import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/voucher_model.dart';
import 'package:prm_project/views/checkout_order/checkout_data.dart';

void main() {
  test('percentage vouchers respect minimum spend and the discount cap', () {
    const voucher = VoucherModel(
      id: 'percent',
      code: 'PERCENT',
      title: 'Discount',
      discountType: 'percentage',
      discountValue: 20,
      minOrderAmount: 50000,
      maxDiscount: 15000,
    );

    expect(checkoutDiscount(voucher, 49999, 18000), 0);
    expect(checkoutDiscount(voucher, 50000, 18000), 10000);
    expect(checkoutDiscount(voucher, 100000, 18000), 15000);
  });

  test('free shipping applies only to the shipping fee', () {
    const voucher = VoucherModel(
      id: 'shipping',
      code: 'SHIP',
      title: 'Free shipping',
      discountType: 'freeship',
      discountValue: 0,
    );

    expect(checkoutDiscount(voucher, 40000, 18000), 18000);
    expect(checkoutDiscount(voucher, 40000, 0), 0);
  });

  test('fixed discounts cannot exceed the items subtotal', () {
    const voucher = VoucherModel(
      id: 'fixed',
      code: 'FIXED',
      title: 'Discount',
      discountType: 'fixed',
      discountValue: 100000,
    );

    expect(checkoutDiscount(voucher, 40000, 18000), 40000);
  });

  test('expired vouchers cannot discount an order', () {
    final voucher = VoucherModel(
      id: 'expired',
      code: 'EXPIRED',
      title: 'Discount',
      discountType: 'fixed',
      discountValue: 10000,
      expiryDate: DateTime.utc(2000),
    );

    expect(checkoutDiscount(voucher, 40000, 18000), 0);
  });
}
