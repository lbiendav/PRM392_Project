import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/product_model.dart';
import 'package:prm_project/providers/catalog_provider.dart';
import 'package:prm_project/providers/favorites_provider.dart';
import 'package:prm_project/repositories/product_repository.dart';
import 'package:prm_project/views/checkout_order/checkout_data.dart';
import 'package:prm_project/views/home_catalog/home_screen.dart';
import 'package:prm_project/views/product_cart/cart_screen.dart';
import 'package:prm_project/views/product_cart/favorites_screen.dart';
import 'package:prm_project/views/product_cart/product_detail_screen.dart';

class EmptyProductRepository extends ProductRepository {
  @override
  Stream<List<ProductModel>> watchProducts() => Stream.value(const []);
}

void main() {
  testWidgets('CoffeeCraft Home smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(EmptyProductRepository()),
        ],
        child: MaterialApp(
          home: HomeScreen(onOpenProduct: (_) {}, onOpenCart: () {}),
        ),
      ),
    );

    expect(find.text('CoffeeCraft'), findsOneWidget);
  });

  testWidgets(
    'Luồng nối màn: Chi tiết món -> Yêu thích -> Đánh giá -> Giỏ hàng -> Đặt hàng -> Ví Voucher',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [checkoutUserIdProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      const sampleProduct = ProductModel(
        id: 'cf-1',
        name: 'Cà phê Sữa Đá',
        price: 35000,
        category: 'coffee',
        rating: 4.9,
        reviewCount: 12,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ProductDetailScreen(product: sampleProduct),
          ),
        ),
      );

      // 1. Toggle yêu thích từ màn Chi tiết món
      await tester.tap(find.byTooltip('Yêu thích'));
      await tester.pump();
      expect(container.read(favoritesProvider).single.id, 'cf-1');

      // 2. Mở màn Đánh giá sản phẩm
      await tester.scrollUntilVisible(
        find.text('Đánh giá'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Đánh giá'));
      await tester.pumpAndSettle();
      expect(find.text('Đánh giá Cà phê Sữa Đá'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 3. Thêm vào giỏ & mở màn Giỏ hàng
      await tester.tap(find.textContaining('Thêm vào giỏ'));
      await tester.pump();
      await tester.tap(find.byTooltip('Giỏ hàng'));
      await tester.pumpAndSettle();
      expect(find.byType(CartScreen), findsOneWidget);

      // 4. Từ Giỏ hàng chuyển sang màn Xác nhận đặt hàng (Member 4)
      await tester.tap(find.text('Tiến hành đặt hàng'));
      await tester.pumpAndSettle();
      expect(find.text('Xác nhận đặt hàng'), findsWidgets);

      // 5. Từ Checkout mở Ví khuyến mãi (Member 5) và chọn voucher
      await tester.tap(find.byTooltip('Chọn từ Ví khuyến mãi'));
      await tester.pumpAndSettle();
      expect(find.text('Ví Khuyến Mãi (Vouchers)'), findsOneWidget);
      await tester.tap(find.text('Chọn').first);
      await tester.pumpAndSettle();
      expect(find.text('FREESHIP18K'), findsOneWidget);
    },
  );

  testWidgets('Màn Yêu thích hiển thị món đã lưu và mở lại Chi tiết món', (
    WidgetTester tester,
  ) async {
    const product = ProductModel(
      id: 'tea-1',
      name: 'Trà Đào Cam Sả',
      price: 45000,
      category: 'tea',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FavoritesScreen(initialFavorites: [product])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trà Đào Cam Sả'), findsOneWidget);
    await tester.tap(find.text('Trà Đào Cam Sả'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết món'), findsOneWidget);
  });
}
