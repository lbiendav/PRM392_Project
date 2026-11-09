import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/product_model.dart';
import 'product_photo.dart';

class ProductTile extends StatelessWidget {
  final ProductModel product;
  final ValueChanged<ProductModel> onOpenProduct;
  const ProductTile({
    super.key,
    required this.product,
    required this.onOpenProduct,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          key: ValueKey('product-${product.id}'),
          onTap: () => onOpenProduct(product),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ProductPhoto(
                      source: product.imageUrl,
                      label: product.name,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.rating} sao · ${product.isAvailable ? 'Đang phục vụ' : 'Tạm hết'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppFormatters.formatCurrency(product.price),
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
