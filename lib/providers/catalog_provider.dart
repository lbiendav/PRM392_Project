import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

part 'catalog_provider.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) => ProductRepository();

@riverpod
Stream<List<ProductModel>> productList(Ref ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
}
