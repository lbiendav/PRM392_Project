import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/models/product_model.dart';
import 'package:prm_project/repositories/product_repository.dart';

void main() {
  test('Loại bản ghi giống hệt nhưng giữ sản phẩm khác giá hoặc kích cỡ', () {
    const products = [
      ProductModel(
        id: 'duplicate-1',
        name: 'Cà phê sữa',
        price: 30000,
        category: 'coffee',
        sizes: ['S', 'M'],
      ),
      ProductModel(
        id: 'duplicate-2',
        name: 'Cà phê sữa',
        price: 30000,
        category: 'coffee',
        sizes: ['M', 'S'],
      ),
      ProductModel(
        id: 'different-price',
        name: 'Cà phê sữa',
        price: 35000,
        category: 'coffee',
        sizes: ['S', 'M'],
      ),
      ProductModel(
        id: 'different-options',
        name: 'Cà phê sữa',
        price: 30000,
        category: 'coffee',
        sizes: ['S', 'M'],
        toppingOptions: [ProductTopping(name: 'Trân châu', price: 5000)],
      ),
    ];

    final result = deduplicateProducts(products);

    expect(result.map((product) => product.id), [
      'duplicate-1',
      'different-price',
      'different-options',
    ]);
  });
}
