import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/catalog_categories.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../viewmodels/catalog_view_model.dart';
import 'widgets/product_card.dart';
import 'widgets/catalog_banner.dart';
import 'widgets/product_tile.dart';

class HomeScreen extends ConsumerWidget {
  final ValueChanged<ProductModel> onOpenProduct;
  final ValueChanged<String>? onOpenCategory;
  final VoidCallback onOpenCart;
  final VoidCallback? onLogout;
  const HomeScreen({
    super.key,
    required this.onOpenProduct,
    required this.onOpenCart,
    this.onOpenCategory,
    this.onLogout,
  });

  void _category(WidgetRef ref, String category) {
    ref.read(homeCategoryViewModelProvider.notifier).selectCategory(category);
    onOpenCategory?.call(category);
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      ref.invalidate(productListProvider);
      await ref.read(productListProvider.future);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không làm mới được dữ liệu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeViewModelProvider);
    final selectedCategory = ref.watch(homeCategoryViewModelProvider);
    final count = ref.watch(cartProvider).totalItemCount;
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('CoffeeCraft'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              key: const Key('open-cart'),
              onPressed: onOpenCart,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text('Giỏ ($count)'),
            ),
          ),
          if (onLogout != null)
            IconButton(
              tooltip: 'Đăng xuất',
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context, ref),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            CatalogBanner(
              onOpenCategory: (category) => _category(ref, category),
            ),
            const SizedBox(height: 24),
            _heading(
              context,
              'Hôm nay bạn muốn gì?',
              'Xem tất cả',
              () => _category(ref, 'all'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52 * scale,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: catalogCategories.entries
                    .where((entry) => entry.key != 'all')
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(entry.value),
                          selected: selectedCategory == entry.key,
                          onSelected: (_) => _category(ref, entry.key),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            home.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Column(
                children: [
                  const Text('Không tải được danh sách món'),
                  TextButton(
                    onPressed: () => _refresh(context, ref),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading(
                    context,
                    'Được yêu thích nhất',
                    '${data.bestSellers.length} món',
                    null,
                  ),
                  const SizedBox(height: 12),
                  if (data.bestSellers.isEmpty)
                    const Text('Chưa có món bán chạy'),
                  if (data.bestSellers.isNotEmpty)
                    SizedBox(
                      height: 292 + (scale - 1) * 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.bestSellers.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 14),
                        itemBuilder: (_, index) => SizedBox(
                          width: 220,
                          child: ProductCard(
                            product: data.bestSellers[index],
                            onOpenProduct: onOpenProduct,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  _heading(
                    context,
                    'Gợi ý cho bạn',
                    'Chọn một chút yêu thích',
                    null,
                  ),
                  const SizedBox(height: 12),
                  if (data.suggestions.isEmpty)
                    const Text('Chưa có món để gợi ý'),
                  ...data.suggestions.map(
                    (product) => ProductTile(
                      product: product,
                      onOpenProduct: onOpenProduct,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback? action,
  ) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        action == null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              )
            : TextButton(onPressed: action, child: Text(subtitle)),
      ],
    );
  }
}
