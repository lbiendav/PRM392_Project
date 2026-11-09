import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/catalog_categories.dart';
import '../../models/product_model.dart';
import '../../providers/catalog_provider.dart';
import '../../viewmodels/catalog_view_model.dart';
import 'widgets/product_card.dart';

class CategoryMenuScreen extends ConsumerStatefulWidget {
  final String initialCategory;
  final ValueChanged<ProductModel> onOpenProduct;

  const CategoryMenuScreen({
    super.key,
    this.initialCategory = 'all',
    required this.onOpenProduct,
  });

  @override
  ConsumerState<CategoryMenuScreen> createState() => _CategoryMenuScreenState();
}

class _CategoryMenuScreenState extends ConsumerState<CategoryMenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _categories = catalogCategories.keys.toList();

  @override
  void initState() {
    super.initState();
    final index = _categories.indexOf(widget.initialCategory);
    _tabs = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: index < 0 ? 0 : index,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = categoryMenuViewModelProvider(widget.initialCategory);
    final products = ref.watch(
      categoryMenuProductsProvider(widget.initialCategory),
    );
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sắp xếp',
            initialValue: ref.watch(provider).sortBy,
            onSelected: ref.read(provider.notifier).setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'default', child: Text('Tên món')),
              PopupMenuItem(value: 'price_asc', child: Text('Giá tăng dần')),
              PopupMenuItem(value: 'price_desc', child: Text('Giá giảm dần')),
              PopupMenuItem(value: 'rating', child: Text('Đánh giá cao nhất')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: catalogCategories.values
              .map((name) => Tab(text: name))
              .toList(),
          onTap: (index) =>
              ref.read(provider.notifier).selectCategory(_categories[index]),
        ),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(productListProvider),
            child: const Text('Lỗi tải món. Thử lại'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Không có món trong danh mục này'))
            : GridView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 320 + (scale - 1) * 150,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (_, index) => ProductCard(
                  product: items[index],
                  onOpenProduct: widget.onOpenProduct,
                  keyPrefix: 'category',
                  hero: true,
                ),
              ),
      ),
    );
  }
}
