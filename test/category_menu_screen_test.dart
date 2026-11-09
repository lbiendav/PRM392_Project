import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/product_model.dart';
import 'package:prm_project/providers/catalog_provider.dart';
import 'package:prm_project/repositories/product_repository.dart';
import 'package:prm_project/views/home_catalog/category_menu_screen.dart';

class CategoryProductsRepository extends ProductRepository {
  @override
  Stream<List<ProductModel>> watchProducts() => Stream.value(const [
    ProductModel(
      id: 'expensive',
      name: 'Apple Coffee',
      price: 60000,
      category: 'coffee',
    ),
    ProductModel(
      id: 'cheap',
      name: 'Zulu Coffee',
      price: 20000,
      category: 'coffee',
    ),
    ProductModel(id: 'tea', name: 'Trà đào', price: 35000, category: 'tea'),
  ]);
}

void main() {
  testWidgets('Lọc theo tab danh mục và sắp xếp theo giá', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            CategoryProductsRepository(),
          ),
        ],
        child: MaterialApp(
          home: CategoryMenuScreen(
            initialCategory: 'coffee',
            onOpenProduct: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apple Coffee'), findsOneWidget);
    expect(find.text('Zulu Coffee'), findsOneWidget);
    expect(find.text('Trà đào'), findsNothing);

    await tester.tap(find.text('Trà hoa quả'));
    await tester.pumpAndSettle();
    expect(find.text('Trà đào'), findsOneWidget);
    expect(find.text('Apple Coffee'), findsNothing);

    await tester.tap(find.text('Cà phê'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sắp xếp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giá tăng dần'));
    await tester.pumpAndSettle();

    final cheapX = tester
        .getTopLeft(find.byKey(const ValueKey('category-cheap')))
        .dx;
    final expensiveX = tester
        .getTopLeft(find.byKey(const ValueKey('category-expensive')))
        .dx;
    expect(cheapX, lessThan(expensiveX));
  });
}
