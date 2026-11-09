import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/product_model.dart';
import 'package:prm_project/providers/catalog_provider.dart';
import 'package:prm_project/repositories/product_repository.dart';
import 'package:prm_project/views/home_catalog/home_screen.dart';

class FakeProductRepository extends ProductRepository {
  @override
  Stream<List<ProductModel>> watchProducts() => Stream.value(const [
    ProductModel(
      id: 'coffee',
      name: 'Cà phê muối',
      price: 39000,
      category: 'coffee',
      isBestSeller: true,
    ),
    ProductModel(
      id: 'tea',
      name: 'Trà đào',
      price: 42000,
      category: 'tea',
      isBestSeller: true,
    ),
  ]);
}

void main() {
  testWidgets('Home hiển thị món và lọc theo danh mục', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(FakeProductRepository()),
        ],
        child: MaterialApp(
          home: HomeScreen(
            onOpenProduct: (_) {},
            onOpenCart: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cà phê muối'), findsWidgets);
    expect(find.text('Trà đào'), findsWidgets);

    await tester.tap(find.widgetWithText(FilterChip, 'Cà phê'));
    await tester.pumpAndSettle();

    expect(find.text('Cà phê muối'), findsWidgets);
    expect(find.text('Trà đào'), findsNothing);
  });
}
