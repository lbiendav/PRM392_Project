import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../models/product_model.dart';

const Map<String, double> toppingPrices = {
  'Trân châu': 5000,
  'Kem cheese': 10000,
  'Shot espresso': 10000,
  'Sốt caramel': 5000,
};

double calculateToppingTotal(Iterable<String> toppings) {
  return toppings.fold(
    0,
    (total, topping) => total + (toppingPrices[topping] ?? 5000),
  );
}

class ToppingCustomizerScreen extends StatefulWidget {
  final ProductModel product;
  final String size;
  final double basePrice;

  const ToppingCustomizerScreen({
    super.key,
    required this.product,
    required this.size,
    required this.basePrice,
  });

  @override
  State<ToppingCustomizerScreen> createState() =>
      _ToppingCustomizerScreenState();
}

class _ToppingCustomizerScreenState extends State<ToppingCustomizerScreen> {
  final Set<String> _selectedToppings = {};
  String _sugar = '100%';
  String _ice = '100%';

  double get _totalPrice =>
      widget.basePrice + calculateToppingTotal(_selectedToppings);

  @override
  Widget build(BuildContext context) {
    final toppings = widget.product.toppings;

    return Scaffold(
      appBar: AppBar(title: const Text('Tùy chỉnh món')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.product.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Size ${widget.size}'),
          const SizedBox(height: 24),
          Text('Mức đường', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['0%', '50%', '100%'].map((value) {
              return ChoiceChip(
                label: Text(value),
                selected: _sugar == value,
                onSelected: (_) => setState(() => _sugar = value),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Mức đá', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Không đá', '50%', '100%'].map((value) {
              return ChoiceChip(
                label: Text(value),
                selected: _ice == value,
                onSelected: (_) => setState(() => _ice = value),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Topping', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (toppings.isEmpty)
            const Text('Món này chưa có topping.')
          else
            ...toppings.map((topping) {
              final price = toppingPrices[topping] ?? 5000;

              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(topping),
                subtitle: Text('+ ${AppFormatters.formatCurrency(price)}'),
                value: _selectedToppings.contains(topping),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedToppings.add(topping);
                    } else {
                      _selectedToppings.remove(topping);
                    }
                  });
                },
              );
            }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).pop({
              'sugar': _sugar,
              'ice': _ice,
              'toppings': _selectedToppings.toList(),
              'price': _totalPrice,
            });
          },
          child: Text(
            'Xác nhận • ${AppFormatters.formatCurrency(_totalPrice)}',
          ),
        ),
      ),
    );
  }
}
