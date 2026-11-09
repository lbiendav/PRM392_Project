import 'package:flutter_riverpod/legacy.dart';
import '../models/product_model.dart';

class FavoritesNotifier extends StateNotifier<List<ProductModel>> {
  FavoritesNotifier() : super(const []);

  bool isFavorite(String productId) {
    return state.any((item) => item.id == productId);
  }

  void toggleFavorite(ProductModel product) {
    if (isFavorite(product.id)) {
      state = state.where((item) => item.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  void removeFavorite(String productId) {
    state = state.where((item) => item.id != productId).toList();
  }

  void seedFavorites(Iterable<ProductModel> products) {
    final existingIds = state.map((item) => item.id).toSet();
    final additions = products
        .where((item) => !existingIds.contains(item.id))
        .toList();
    if (additions.isNotEmpty) {
      state = [...state, ...additions];
    }
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<ProductModel>>((ref) {
      return FavoritesNotifier();
    });
