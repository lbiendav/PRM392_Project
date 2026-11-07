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
      (snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList(),
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
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
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
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
