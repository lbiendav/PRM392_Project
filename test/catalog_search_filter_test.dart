import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/catalog_filter.dart';
import 'package:prm_project/models/product_model.dart';
import 'package:prm_project/viewmodels/catalog_view_model.dart';

void main() {
  const products = [
    ProductModel(
      id: 'salt',
      name: 'Cà phê muối',
      price: 35000,
      rating: 4.8,
      isBestSeller: true,
    ),
    ProductModel(id: 'tea', name: 'Trà đào', price: 45000, rating: 4.6),
    ProductModel(
      id: 'cake',
      name: 'Bánh mousse',
      price: 38000,
      rating: 4.9,
      isAvailable: false,
    ),
  ];

  test('search ignores Vietnamese accents and case', () {
    final result = filterCatalogProducts(products, query: 'CA PHE MUOI');
    expect(result.map((product) => product.id), ['salt']);
  });

  test('catalog filters price, rating, best seller and sorting', () {
    final result = filterCatalogProducts(
      products,
      filter: const CatalogFilter(
        minPrice: 30000,
        maxPrice: 40000,
        minRating: 4.5,
        bestSellerOnly: true,
        sortBy: 'price_desc',
      ),
    );
    expect(result.map((product) => product.id), ['salt']);
  });
}
