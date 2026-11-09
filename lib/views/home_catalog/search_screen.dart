import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/catalog_filter.dart';
import '../../models/product_model.dart';
import '../../providers/catalog_provider.dart';
import '../../viewmodels/catalog_view_model.dart';
import 'advanced_filter_screen.dart';
import 'widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final ValueChanged<ProductModel> onOpenProduct;
  const SearchScreen({super.key, required this.onOpenProduct});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final current = ref.read(searchViewModelProvider).filter;
    final filter = await Navigator.of(context).push<CatalogFilter>(
      MaterialPageRoute(builder: (_) => AdvancedFilterScreen(initial: current)),
    );
    if (filter != null) {
      ref.read(searchViewModelProvider.notifier).setFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchViewModelProvider);
    final history = ref.watch(searchHistoryProvider);
    final results = ref.watch(searchResultsProvider);
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm món')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('catalog-search-field'),
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onChanged: ref
                        .read(searchViewModelProvider.notifier)
                        .setQuery,
                    onSubmitted: (value) => ref
                        .read(searchViewModelProvider.notifier)
                        .submit(value),
                    decoration: InputDecoration(
                      hintText: 'Tên món, nguyên liệu...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchViewModelProvider.notifier).clear();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('open-advanced-filter'),
                  tooltip: 'Bộ lọc nâng cao',
                  onPressed: _openFilters,
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          if (search.query.isEmpty)
            history.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (items) => items.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text('Tìm gần đây')),
                              TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(
                                        catalogPreferencesRepositoryProvider,
                                      )
                                      .clearHistory();
                                  ref.invalidate(searchHistoryProvider);
                                },
                                child: const Text('Xóa lịch sử'),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 8,
                            children: items
                                .map(
                                  (item) => ActionChip(
                                    label: Text(item),
                                    onPressed: () {
                                      _controller.text = item;
                                      ref
                                          .read(
                                            searchViewModelProvider.notifier,
                                          )
                                          .submit(item);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
            ),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Không tải được món'),
                    TextButton(
                      onPressed: () => ref.invalidate(productListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('Không tìm thấy món phù hợp'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisExtent: 320 + (scale - 1) * 150,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (_, index) => ProductCard(
                        keyPrefix: 'search',
                        product: items[index],
                        onOpenProduct: widget.onOpenProduct,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
