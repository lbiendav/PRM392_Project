class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category; // 'coffee', 'tea', 'bakery', 'bottle'
  final List<String> sizes; // ['S', 'M', 'L']
  final List<String> toppings;
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
    this.sizes = const ['S', 'M', 'L'],
    this.toppings = const [],
    this.rating = 5.0,
    this.reviewCount = 0,
    this.isBestSeller = false,
    this.isAvailable = true,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'coffee',
      sizes: List<String>.from(map['sizes'] ?? const ['S', 'M', 'L']),
      toppings: List<String>.from(map['toppings'] ?? const []),
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
      'sizes': sizes,
      'toppings': toppings,
      'rating': rating,
      'reviewCount': reviewCount,
      'isBestSeller': isBestSeller,
      'isAvailable': isAvailable,
    };
  }
}
