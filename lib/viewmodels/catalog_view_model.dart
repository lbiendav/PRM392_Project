import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

import '../core/constants/catalog_categories.dart';
import '../models/product_model.dart';
import '../models/catalog_filter.dart';
import '../models/branch_model.dart';
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

String normalizeCatalogText(String value) {
  const vietnamese = {
    'áàảãạăắằẳẵặâấầẩẫậ': 'a',
    'éèẻẽẹêếềểễệ': 'e',
    'íìỉĩị': 'i',
    'óòỏõọôốồổỗộơớờởỡợ': 'o',
    'úùủũụưứừửữự': 'u',
    'ýỳỷỹỵ': 'y',
    'đ': 'd',
  };
  var result = value.toLowerCase();
  vietnamese.forEach((chars, replacement) {
    for (final char in chars.split('')) {
      result = result.replaceAll(char, replacement);
    }
  });
  return result;
}

List<ProductModel> filterCatalogProducts(
  Iterable<ProductModel> products, {
  String query = '',
  CatalogFilter filter = const CatalogFilter(),
}) {
  final normalized = normalizeCatalogText(query.trim());
  final results = products.where((product) {
    final matchesQuery =
        normalized.isEmpty ||
        normalizeCatalogText(
          '${product.name} ${product.description}',
        ).contains(normalized);
    return product.isAvailable &&
        matchesQuery &&
        product.price >= filter.minPrice &&
        product.price <= filter.maxPrice &&
        product.rating >= filter.minRating &&
        (!filter.bestSellerOnly || product.isBestSeller);
  }).toList();
  results.sort(
    (a, b) => switch (filter.sortBy) {
      'price_asc' => a.price.compareTo(b.price),
      'price_desc' => b.price.compareTo(a.price),
      'rating' => b.rating.compareTo(a.rating),
      'name' => a.name.compareTo(b.name),
      _ => 0,
    },
  );
  return results;
}

class SearchState {
  final String query;
  final CatalogFilter filter;
  const SearchState({this.query = '', this.filter = const CatalogFilter()});
  SearchState copyWith({String? query, CatalogFilter? filter}) =>
      SearchState(query: query ?? this.query, filter: filter ?? this.filter);
}

@riverpod
class SearchViewModel extends _$SearchViewModel {
  Timer? _timer;
  @override
  SearchState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SearchState();
  }

  void setQuery(String query) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(query: query);
    });
  }

  Future<void> submit(String query) async {
    _timer?.cancel();
    state = state.copyWith(query: query);
    await ref.read(catalogPreferencesRepositoryProvider).addKeyword(query);
    ref.invalidate(searchHistoryProvider);
  }

  void setFilter(CatalogFilter filter) =>
      state = state.copyWith(filter: filter);
  void clear() {
    _timer?.cancel();
    state = state.copyWith(query: '');
  }
}

@riverpod
AsyncValue<List<ProductModel>> searchResults(Ref ref) {
  final state = ref.watch(searchViewModelProvider);
  return ref
      .watch(productListProvider)
      .whenData(
        (products) => filterCatalogProducts(
          products,
          query: state.query,
          filter: state.filter,
        ),
      );
}

class BranchListState {
  final String query;
  final bool openOnly;
  const BranchListState({this.query = '', this.openOnly = false});
  BranchListState copyWith({String? query, bool? openOnly}) => BranchListState(
    query: query ?? this.query,
    openOnly: openOnly ?? this.openOnly,
  );
}

@riverpod
class BranchViewModel extends _$BranchViewModel {
  @override
  BranchListState build() => const BranchListState();
  void setQuery(String query) => state = state.copyWith(query: query);
  void setOpenOnly(bool value) => state = state.copyWith(openOnly: value);

  Future<bool> select(BranchModel branch, DateTime now) async {
    if (!branch.isActive || !branch.isOpenAt(now)) return false;
    await ref.read(catalogPreferencesRepositoryProvider).setBranchId(branch.id);
    ref.invalidate(selectedBranchProvider);
    return true;
  }

  Future<bool> callStore(String phone) =>
      ref.read(storeContactRepositoryProvider).call(phone);
}

@riverpod
AsyncValue<List<BranchModel>> visibleBranches(Ref ref) {
  final state = ref.watch(branchViewModelProvider);
  final now = ref.watch(catalogClockProvider).value ?? DateTime.now();
  return ref.watch(branchListProvider).whenData((branches) {
    final query = normalizeCatalogText(state.query.trim());
    return branches.where((branch) {
      final matches =
          query.isEmpty ||
          normalizeCatalogText(
            '${branch.name} ${branch.address}',
          ).contains(query);
      return matches && (!state.openOnly || branch.isOpenAt(now));
    }).toList();
  });
}

@riverpod
Future<BranchModel?> selectedBranch(Ref ref) async {
  final id = await ref.read(catalogPreferencesRepositoryProvider).getBranchId();
  if (id == null) return null;
  try {
    return await ref.read(branchRepositoryProvider).getBranch(id);
  } catch (_) {
    return null;
  }
}
