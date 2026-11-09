import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../home_catalog/widgets/product_photo.dart';
import 'cart_screen.dart';
import 'product_reviews_screen.dart';
import 'topping_customizer_screen.dart';

double productPriceForSize(double basePrice, String size) {
  return basePrice +
      switch (size) {
        'M' => 5000,
        'L' => 10000,
        _ => 0,
      };
}

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late String _selectedSize;
  int _sugarPercent = 100;
  String _iceLevel = 'normal';
  final Set<String> _selectedToppings = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.contains('M')
        ? 'M'
        : widget.product.sizes.isEmpty
        ? 'M'
        : widget.product.sizes.first;
  }

  double get _unitPrice =>
      productPriceForSize(widget.product.price, _selectedSize) +
      widget.product.toppingOptions
          .where((topping) => _selectedToppings.contains(topping.name))
          .fold(0.0, (sum, topping) => sum + topping.price);

  void _addToCart() {
    ref
        .read(cartProvider.notifier)
        .addItem(
          OrderItemModel(
            productId: widget.product.id,
            productName: widget.product.name,
            imageUrl: widget.product.imageUrl,
            price: _unitPrice,
            quantity: _quantity,
            size: _selectedSize,
            toppings: _selectedToppings.toList()..sort(),
            sugarPercent: widget.product.supportsDrinkOptions
                ? _sugarPercent
                : null,
            iceLevel: widget.product.supportsDrinkOptions ? _iceLevel : null,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${widget.product.name} vào giỏ hàng'),
        action: SnackBarAction(
          label: 'Xem giỏ',
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen()));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (items) => items.any((item) => item.id == product.id),
      ),
    );
    final cartCount = ref.watch(cartProvider).totalItemCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết món'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Đã xóa khỏi danh sách yêu thích'
                        : 'Đã thêm vào danh sách yêu thích',
                  ),
                ),
              );
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
          IconButton(
            tooltip: 'Giỏ hàng',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CartScreen()),
              );
            },
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ProductPhoto(
                source: product.imageUrl,
                label: product.name,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(product.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text('${product.rating} (${product.reviewCount} đánh giá)'),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductReviewsScreen(
                        productId: product.id,
                        productName: product.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Đánh giá'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description.isEmpty
                ? 'Chưa có mô tả cho sản phẩm này.'
                : product.description,
          ),
          if (product.sizes.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Chọn kích cỡ', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: product.sizes.map((size) {
                return ChoiceChip(
                  label: Text(size),
                  selected: _selectedSize == size,
                  onSelected: (_) {
                    setState(() => _selectedSize = size);
                  },
                );
              }).toList(),
            ),
          ],
          if (product.supportsDrinkOptions) ...[
            const SizedBox(height: 24),
            Text('Lượng đường', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [0, 30, 50, 70, 100].map((percent) {
                return ChoiceChip(
                  label: Text('$percent%'),
                  selected: _sugarPercent == percent,
                  onSelected: (_) => setState(() => _sugarPercent = percent),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Lượng đá', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  const {
                    'normal': 'Bình thường',
                    'less': 'Ít đá',
                    'none': 'Không đá',
                  }.entries.map((entry) {
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: _iceLevel == entry.key,
                      onSelected: (_) => setState(() => _iceLevel = entry.key),
                    );
                  }).toList(),
            ),
            if (product.toppingOptions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Topping', style: theme.textTheme.titleMedium),
              ...product.toppingOptions.map(
                (topping) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(topping.name),
                  subtitle: Text(
                    '+ ${AppFormatters.formatCurrency(topping.price)}',
                  ),
                  value: _selectedToppings.contains(topping.name),
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        _selectedToppings.add(topping.name);
                      } else {
                        _selectedToppings.remove(topping.name);
                      }
                    });
                  },
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          Text('Số lượng', style: theme.textTheme.titleMedium),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Giảm số lượng',
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_quantity', style: theme.textTheme.titleMedium),
                  IconButton(
                    tooltip: 'Tăng số lượng',
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: product.isAvailable ? _customizeAndAdd : null,
                icon: const Icon(Icons.tune),
                label: const Text('Tùy chỉnh topping và thêm vào giỏ'),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: product.isAvailable ? _addToCart : null,
          icon: const Icon(Icons.add_shopping_cart),
          label: Text(
            product.isAvailable
                ? 'Thêm vào giỏ • ${AppFormatters.formatCurrency(_unitPrice * _quantity)}'
                : 'Sản phẩm tạm hết',
          ),
        ),
      ),
    );
  }

  Future<void> _customizeAndAdd() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ToppingCustomizerScreen(
          product: widget.product,
          size: _selectedSize,
          basePrice: _unitPrice,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final toppings = List<String>.from(result['toppings'] as List);
    final price = result['price'] as double;
    final sugar = result['sugar'] as String;
    final ice = result['ice'] as String;

    ref
        .read(cartProvider.notifier)
        .addItem(
          OrderItemModel(
            productId: widget.product.id,
            productName: widget.product.name,
            imageUrl: widget.product.imageUrl,
            price: price,
            quantity: _quantity,
            size: _selectedSize,
            toppings: toppings,
            note: 'Đường: $sugar, đá: $ice',
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm món tùy chỉnh vào giỏ hàng')),
    );
  }
}
