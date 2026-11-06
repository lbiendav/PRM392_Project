import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/views/product_cart/product_detail_screen.dart';

void main() {
  test('tính đúng giá theo kích cỡ', () {
    expect(productPriceForSize(30000, 'S'), 30000);
    expect(productPriceForSize(30000, 'M'), 35000);
    expect(productPriceForSize(30000, 'L'), 40000);
  });
}
