class CatalogFilter {
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final bool bestSellerOnly;
  final String sortBy;

  const CatalogFilter({
    this.minPrice = 0,
    this.maxPrice = 150000,
    this.minRating = 0,
    this.bestSellerOnly = false,
    this.sortBy = 'default',
  });

  CatalogFilter copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? bestSellerOnly,
    String? sortBy,
  }) {
    return CatalogFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      bestSellerOnly: bestSellerOnly ?? this.bestSellerOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get isDefault => this == const CatalogFilter();

  @override
  bool operator ==(Object other) =>
      other is CatalogFilter &&
      minPrice == other.minPrice &&
      maxPrice == other.maxPrice &&
      minRating == other.minRating &&
      bestSellerOnly == other.bestSellerOnly &&
      sortBy == other.sortBy;

  @override
  int get hashCode =>
      Object.hash(minPrice, maxPrice, minRating, bestSellerOnly, sortBy);
}
