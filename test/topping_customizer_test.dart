import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/views/product_cart/topping_customizer_screen.dart';

void main() {
  test('tính tổng giá topping', () {
    expect(calculateToppingTotal(['Trân châu', 'Kem cheese']), 15000);
  });

  test('topping chưa có trong bảng dùng giá mặc định', () {
    expect(calculateToppingTotal(['Topping mới']), 5000);
  });
}
