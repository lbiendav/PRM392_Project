import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

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
      productPriceForSize(widget.product.price, _selectedSize);

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
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${widget.product.name} vào giỏ hàng')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết món')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl.isEmpty
                  ? const ColoredBox(
                      color: Colors.black12,
                      child: Icon(Icons.local_cafe, size: 72),
                    )
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      semanticLabel: product.name,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.broken_image_outlined, size: 64),
                      ),
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
          const SizedBox(height: 24),
          Text('Số lượng', style: theme.textTheme.titleMedium),
          Row(
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
}
