import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product_model.dart';
import 'product_photo.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final ValueChanged<ProductModel> onOpenProduct;
  final String keyPrefix;
  final bool hero;
  const ProductCard({
    super.key,
    required this.product,
    required this.onOpenProduct,
    this.keyPrefix = 'product',
    this.hero = false,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final photo = ProductPhoto(source: product.imageUrl, label: product.name);
    return Card(
      child: InkWell(
        key: ValueKey('$keyPrefix-${product.id}'),
        onTap: () => onOpenProduct(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hero
                      ? Hero(tag: 'product-${product.id}', child: photo)
                      : photo,
                  if (product.isBestSeller)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Text(
                            'Bán chạy',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: colors.primary, size: 17),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '(${product.reviewCount})',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppFormatters.formatCurrency(product.price),
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: colors.primary,
                      ),
                    ],
                  ),
                  if (!product.isAvailable)
                    Text('Tạm hết', style: TextStyle(color: colors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
