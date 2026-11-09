import 'package:flutter/material.dart';
import '../../models/catalog_filter.dart';

class AdvancedFilterScreen extends StatefulWidget {
  final CatalogFilter initial;
  const AdvancedFilterScreen({super.key, this.initial = const CatalogFilter()});

  @override
  State<AdvancedFilterScreen> createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends State<AdvancedFilterScreen> {
  late double _minPrice;
  late double _maxPrice;
  late double _rating;
  late bool _bestSeller;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initial.minPrice;
    _maxPrice = widget.initial.maxPrice;
    _rating = widget.initial.minRating;
    _bestSeller = widget.initial.bestSellerOnly;
    _sortBy = widget.initial.sortBy;
  }

  void _reset() => setState(() {
    _minPrice = 0;
    _maxPrice = 150000;
    _rating = 0;
    _bestSeller = false;
    _sortBy = 'default';
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ lọc nâng cao'),
        actions: [TextButton(onPressed: _reset, child: const Text('Đặt lại'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Khoảng giá: ${_minPrice.round()} – ${_maxPrice.round()} đ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RangeSlider(
            key: const Key('price-range-filter'),
            min: 0,
            max: 150000,
            divisions: 30,
            values: RangeValues(_minPrice, _maxPrice),
            labels: RangeLabels('${_minPrice.round()}', '${_maxPrice.round()}'),
            onChanged: (range) => setState(() {
              _minPrice = range.start;
              _maxPrice = range.end;
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Đánh giá tối thiểu: ${_rating == 0 ? 'Tất cả' : _rating.toStringAsFixed(1)} sao',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            key: const Key('minimum-rating-filter'),
            min: 0,
            max: 5,
            divisions: 10,
            value: _rating,
            onChanged: (value) => setState(() => _rating = value),
          ),
          SwitchListTile(
            key: const Key('best-seller-filter'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Chỉ món bán chạy'),
            value: _bestSeller,
            onChanged: (value) => setState(() => _bestSeller = value),
          ),
          const SizedBox(height: 16),
          Text('Sắp xếp', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: const Key('catalog-sort-filter'),
            initialValue: _sortBy,
            items: const [
              DropdownMenuItem(value: 'default', child: Text('Mặc định')),
              DropdownMenuItem(value: 'price_asc', child: Text('Giá tăng dần')),
              DropdownMenuItem(
                value: 'price_desc',
                child: Text('Giá giảm dần'),
              ),
              DropdownMenuItem(
                value: 'rating',
                child: Text('Đánh giá cao nhất'),
              ),
              DropdownMenuItem(value: 'name', child: Text('Tên món')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _sortBy = value);
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('apply-catalog-filters'),
            onPressed: () => Navigator.pop(
              context,
              CatalogFilter(
                minPrice: _minPrice,
                maxPrice: _maxPrice,
                minRating: _rating,
                bestSellerOnly: _bestSeller,
                sortBy: _sortBy,
              ),
            ),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }
}
