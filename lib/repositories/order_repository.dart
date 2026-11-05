import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCol =>
      _firestore.collection(AppConstants.colOrders);

  /// Tạo đơn hàng mới
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersCol.add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi tạo đơn hàng: $e';
    }
  }

  /// Lấy danh sách đơn hàng của người dùng theo trạng thái
  Stream<List<OrderModel>> watchUserOrders(String userId, {String? status}) {
    Query<Map<String, dynamic>> query = _ordersCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (status != null && status.isNotEmpty && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Lấy chi tiết đơn hàng theo ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCol.doc(orderId).get();
      if (!doc.exists || doc.data() == null) return null;
      return OrderModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw 'Không thể tải chi tiết đơn hàng: $e';
    }
  }
}
