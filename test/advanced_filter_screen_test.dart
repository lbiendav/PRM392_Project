import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/catalog_filter.dart';
import 'package:prm_project/views/home_catalog/advanced_filter_screen.dart';

void main() {
  testWidgets('applies catalog filters without drink customization fields', (
    tester,
  ) async {
    CatalogFilter? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                applied = await Navigator.push<CatalogFilter>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdvancedFilterScreen(),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('best-seller-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('apply-catalog-filters')));
    await tester.pumpAndSettle();

    expect(applied?.bestSellerOnly, isTrue);
    expect(applied?.minRating, 0);
  });
}
