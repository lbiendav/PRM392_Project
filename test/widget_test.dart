import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/models/product_model.dart';
import 'package:prm_project/providers/catalog_provider.dart';
import 'package:prm_project/repositories/product_repository.dart';
import 'package:prm_project/views/home_catalog/home_screen.dart';

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
}
