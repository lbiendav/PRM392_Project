import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/order_model.dart';
import 'package:prm_project/providers/cart_provider.dart';

void main() {
  test('tăng giảm số lượng và tính subtotal', () {
    final cart = CartNotifier();

    cart.addItem(
      const OrderItemModel(
        productId: 'coffee-1',
        productName: 'Cà phê sữa',
        price: 30000,
        quantity: 1,
      ),
    );

    cart.updateQuantity(0, 2);

    expect(cart.state.items.first.quantity, 2);
    expect(cart.state.subtotal, 60000);
  });

  test('số lượng bằng 0 sẽ xóa món', () {
    final cart = CartNotifier();

    cart.addItem(
      const OrderItemModel(
        productId: 'coffee-1',
        productName: 'Cà phê sữa',
        price: 30000,
        quantity: 1,
      ),
    );

    cart.updateQuantity(0, 0);

    expect(cart.state.items, isEmpty);
  });
}
