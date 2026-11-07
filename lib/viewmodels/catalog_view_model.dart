import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/product_model.dart';
import '../providers/catalog_provider.dart';

part 'catalog_view_model.g.dart';

class HomeData {
  final List<ProductModel> bestSellers;
  final List<ProductModel> suggestions;

  const HomeData(this.bestSellers, this.suggestions);
}

@riverpod
class HomeCategoryViewModel extends _$HomeCategoryViewModel {
  @override
  String build() => 'all';

  void selectCategory(String category) => state = category;
}

@riverpod
AsyncValue<HomeData> homeViewModel(Ref ref) {
  final category = ref.watch(homeCategoryViewModelProvider);
  return ref.watch(productListProvider).whenData((products) {
    final available = products
        .where(
          (product) =>
              product.isAvailable &&
              (category == 'all' || product.category == category),
        )
        .toList();
    final bestSellers = available
        .where((product) => product.isBestSeller)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final suggestions = available.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return HomeData(
      bestSellers.take(10).toList(),
      suggestions.take(6).toList(),
    );
  });
}
