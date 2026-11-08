import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/product_model.dart';
import '../models/branch_model.dart';
import '../repositories/product_repository.dart';
import '../repositories/branch_repository.dart';
import '../repositories/catalog_preferences_repository.dart';
import '../repositories/store_contact_repository.dart';

part 'catalog_provider.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) => ProductRepository();

@riverpod
Stream<List<ProductModel>> productList(Ref ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
}

@Riverpod(keepAlive: true)
BranchRepository branchRepository(Ref ref) => BranchRepository();

@riverpod
Stream<List<BranchModel>> branchList(Ref ref) =>
    ref.watch(branchRepositoryProvider).watchBranches();

@Riverpod(keepAlive: true)
CatalogPreferencesRepository catalogPreferencesRepository(Ref ref) =>
    CatalogPreferencesRepository();

@Riverpod(keepAlive: true)
StoreContactRepository storeContactRepository(Ref ref) =>
    StoreContactRepository();

@riverpod
Future<List<String>> searchHistory(Ref ref) =>
    ref.watch(catalogPreferencesRepositoryProvider).getHistory();

@riverpod
Stream<DateTime> catalogClock(Ref ref) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  );
}
