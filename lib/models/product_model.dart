class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category; // 'coffee', 'tea', 'bakery', 'bottle'
  final bool supportsDrinkOptions;
  final List<String> sizes; // ['S', 'M', 'L']
  final List<String> toppings;
  final List<ProductTopping> toppingOptions;
  final double rating;
  final int reviewCount;
  final bool isBestSeller;
  final bool isAvailable;

  const ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.imageUrl = '',
    this.category = 'coffee',
    bool? supportsDrinkOptions,
    this.sizes = const ['S', 'M', 'L'],
    this.toppings = const [],
    this.toppingOptions = const [],
    this.rating = 5.0,
    this.reviewCount = 0,
    this.isBestSeller = false,
    this.isAvailable = true,
  }) : supportsDrinkOptions =
           supportsDrinkOptions ?? (category == 'coffee' || category == 'tea');

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    final rawOptions = map['toppingOptions'] as List<dynamic>? ?? const [];
    final category = map['category'] as String?;
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      category: category ?? 'coffee',
      supportsDrinkOptions:
          map['supportsDrinkOptions'] as bool? ??
          (category == 'coffee' || category == 'tea'),
      sizes: List<String>.from(map['sizes'] ?? const ['S', 'M', 'L']),
      toppings: List<String>.from(map['toppings'] ?? const []),
      toppingOptions: rawOptions
          .whereType<Map>()
          .map(
            (option) =>
                ProductTopping.tryFromMap(Map<String, dynamic>.from(option)),
          )
          .whereType<ProductTopping>()
          .toList(),
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isBestSeller: map['isBestSeller'] as bool? ?? false,
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'supportsDrinkOptions': supportsDrinkOptions,
      'sizes': sizes,
      'toppings': toppings,
      'toppingOptions': toppingOptions.map((option) => option.toMap()).toList(),
      'rating': rating,
      'reviewCount': reviewCount,
      'isBestSeller': isBestSeller,
      'isAvailable': isAvailable,
    };
  }
}

class ProductTopping {
  final String name;
  final double price;

  const ProductTopping({required this.name, required this.price});

  static ProductTopping? tryFromMap(Map<String, dynamic> map) {
    final name = map['name'];
    final price = map['price'];
    if (name is! String ||
        name.trim().isEmpty ||
        price is! num ||
        !price.toDouble().isFinite ||
        price < 0) {
      return null;
    }
    return ProductTopping(name: name, price: price.toDouble());
  }

  Map<String, dynamic> toMap() => {'name': name, 'price': price};
}
