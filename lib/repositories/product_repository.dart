import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore? firestore;

  ProductRepository({this.firestore});

  CollectionReference<Map<String, dynamic>> get _productsCol =>
      (firestore ?? FirebaseFirestore.instance).collection(
        AppConstants.colProducts,
      );

  Stream<List<ProductModel>> watchProducts() {
    return _productsCol.snapshots().map(
      (snapshot) => deduplicateProducts(
        snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)),
      ),
    );
  }

  /// Lấy danh sách sản phẩm theo danh mục (hoặc toàn bộ)
  Future<List<ProductModel>> getProducts({String? category}) async {
    try {
      Query<Map<String, dynamic>> query = _productsCol;
      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }
      final snapshot = await query.get();
      return deduplicateProducts(
        snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)),
      );
    } catch (e) {
      throw 'Không thể tải danh sách sản phẩm: $e';
    }
  }

  /// Stream danh sách sản phẩm bán chạy (Best sellers)
  Stream<List<ProductModel>> watchBestSellers() {
    return _productsCol
        .where('isBestSeller', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => deduplicateProducts(
            snapshot.docs.map(
              (doc) => ProductModel.fromMap(doc.data(), doc.id),
            ),
          ),
        );
  }
}

List<ProductModel> deduplicateProducts(Iterable<ProductModel> products) {
  final seen = <String>{};
  return products
      .where((product) => seen.add(_productFingerprint(product)))
      .toList();
}

String _productFingerprint(ProductModel product) {
  final sizes = [...product.sizes]..sort();
  final toppings = [...product.toppings]..sort();
  final toppingOptions =
      product.toppingOptions
          .map((option) => [option.name.trim(), option.price])
          .toList()
        ..sort((a, b) => jsonEncode(a).compareTo(jsonEncode(b)));
  return jsonEncode([
    product.name.trim().toLowerCase(),
    product.description.trim().toLowerCase(),
    product.price,
    product.imageUrl.trim(),
    product.category,
    product.supportsDrinkOptions,
    sizes,
    toppings,
    toppingOptions,
    product.rating,
    product.reviewCount,
    product.isBestSeller,
    product.isAvailable,
  ]);
}
