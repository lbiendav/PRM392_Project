import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/order_model.dart';
import 'package:prm_project/models/product_model.dart';
import 'package:prm_project/providers/cart_provider.dart';
import 'package:prm_project/views/product_cart/product_detail_screen.dart';

void main() {
  testWidgets('Đồ uống lưu tuỳ chọn và cộng giá topping từ dữ liệu', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ProductDetailScreen(
            product: const ProductModel(
              id: 'milk-tea',
              name: 'Trà sữa',
              category: 'tea',
              price: 30000,
              toppingOptions: [ProductTopping(name: 'Trân châu', price: 7000)],
            ),
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('50%'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('50%'));
    await tester.scrollUntilVisible(
      find.text('Ít đá'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Ít đá'));
    await tester.scrollUntilVisible(
      find.text('Trân châu'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Trân châu'));
    await tester.tap(find.textContaining('Thêm vào giỏ'));
    await tester.pump();

    final item = container.read(cartProvider).items.single;
    expect(item.sugarPercent, 50);
    expect(item.iceLevel, 'less');
    expect(item.toppings, ['Trân châu']);
    expect(item.price, 42000);
  });

  testWidgets('Món không phải đồ uống không hiện tuỳ chọn đường đá topping', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProductDetailScreen(
            product: const ProductModel(
              id: 'cake',
              name: 'Bánh ngọt',
              category: 'bakery',
              price: 20000,
              toppingOptions: [ProductTopping(name: 'Kem', price: 5000)],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Lượng đường'), findsNothing);
    expect(find.text('Lượng đá'), findsNothing);
    expect(find.text('Kem'), findsNothing);
  });

  test('Giỏ gộp cấu hình giống nhau và tách cấu hình khác nhau', () {
    final cart = CartNotifier();
    const milkTea = OrderItemModel(
      productId: 'milk-tea',
      productName: 'Trà sữa',
      price: 42000,
      quantity: 1,
      size: 'M',
      sugarPercent: 50,
      iceLevel: 'less',
      toppings: ['Trân châu'],
    );

    cart.addItem(milkTea);
    cart.addItem(milkTea.copyWith(quantity: 2));
    cart.addItem(
      const OrderItemModel(
        productId: 'milk-tea',
        productName: 'Trà sữa',
        price: 42000,
        quantity: 1,
        size: 'M',
        sugarPercent: 100,
        iceLevel: 'less',
        toppings: ['Trân châu'],
      ),
    );

    expect(cart.state.items, hasLength(2));
    expect(cart.state.items.first.quantity, 3);
    expect(cart.state.subtotal, 168000);
    cart.dispose();
  });

  test('Đơn hàng serialize và đọc lại tuỳ chọn đồ uống', () {
    const item = OrderItemModel(
      productId: 'milk-tea',
      productName: 'Trà sữa',
      price: 42000,
      quantity: 1,
      sugarPercent: 30,
      iceLevel: 'none',
      toppings: ['Trân châu'],
    );

    final restored = OrderItemModel.fromMap(item.toMap());

    expect(restored.sugarPercent, 30);
    expect(restored.iceLevel, 'none');
    expect(restored.toppings, ['Trân châu']);
  });
}
