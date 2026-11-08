import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/catalog_categories.dart';
import '../models/product_model.dart';
import '../providers/catalog_provider.dart';

part 'catalog_view_model.g.dart';

class HomeData {
  final List<ProductModel> bestSellers;
  final List<ProductModel> suggestions;

  const HomeData(this.bestSellers, this.suggestions);
}

class CategoryMenuState {
  final String category;
  final String sortBy;

  const CategoryMenuState({required this.category, this.sortBy = 'default'});

  CategoryMenuState copyWith({String? category, String? sortBy}) {
    return CategoryMenuState(
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

@riverpod
class HomeCategoryViewModel extends _$HomeCategoryViewModel {
  @override
  String build() => 'all';

  void selectCategory(String category) => state = category;
}

@riverpod
class CategoryMenuViewModel extends _$CategoryMenuViewModel {
  @override
  CategoryMenuState build(String initialCategory) {
    final category = catalogCategories.containsKey(initialCategory)
        ? initialCategory
        : 'all';
    return CategoryMenuState(category: category);
  }

  void selectCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setSort(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }
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
    final bestSellers =
        available.where((product) => product.isBestSeller).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
    final suggestions = available.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return HomeData(
      bestSellers.take(10).toList(),
      suggestions.take(6).toList(),
    );
  });
}

@riverpod
AsyncValue<List<ProductModel>> categoryMenuProducts(
  Ref ref,
  String initialCategory,
) {
  final selection = ref.watch(categoryMenuViewModelProvider(initialCategory));
  return ref.watch(productListProvider).whenData((products) {
    final result = products
        .where(
          (product) =>
              product.isAvailable &&
              (selection.category == 'all' ||
                  product.category == selection.category),
        )
        .toList();
    result.sort((a, b) {
      return switch (selection.sortBy) {
        'price_asc' => a.price.compareTo(b.price),
        'price_desc' => b.price.compareTo(a.price),
        'rating' => b.rating.compareTo(a.rating),
        _ => a.name.compareTo(b.name),
      };
    });
    return result;
  });
}
