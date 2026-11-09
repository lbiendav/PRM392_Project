import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../home_catalog/widgets/product_photo.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  final List<ProductModel> initialFavorites;

  const FavoritesScreen({super.key, this.initialFavorites = const []});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialFavorites.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(favoritesProvider.notifier)
              .seedFavorites(widget.initialFavorites);
        }
      });
    }
  }

  void _addToCart(ProductModel product) {
    ref
        .read(cartProvider.notifier)
        .addItem(
          OrderItemModel(
            productId: product.id,
            productName: product.name,
            imageUrl: product.imageUrl,
            price: product.price,
            quantity: 1,
            size: product.sizes.contains('M')
                ? 'M'
                : product.sizes.firstOrNull ?? 'M',
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${product.name} vào giỏ hàng')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Món yêu thích')),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64),
                  SizedBox(height: 12),
                  Text('Bạn chưa có món yêu thích'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ProductPhoto(
                          source: product.imageUrl,
                          label: product.name,
                        ),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(AppFormatters.formatCurrency(product.price)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Thêm vào giỏ hàng',
                          onPressed: product.isAvailable
                              ? () => _addToCart(product)
                              : null,
                          icon: const Icon(Icons.add_shopping_cart),
                        ),
                        IconButton(
                          tooltip: 'Bỏ yêu thích',
                          onPressed: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .removeFavorite(product.id);
                          },
                          icon: const Icon(Icons.favorite, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
