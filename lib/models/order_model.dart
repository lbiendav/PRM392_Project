import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String size;
  final List<String> toppings;
  final String note;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    this.imageUrl = '',
    required this.price,
    required this.quantity,
    this.size = 'M',
    this.toppings = const [],
    this.note = '',
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      size: map['size'] as String? ?? 'M',
      toppings: List<String>.from(map['toppings'] ?? const []),
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'size': size,
      'toppings': toppings,
      'note': note,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double totalAmount;
  final String deliveryType; // 'delivery' | 'pickup'
  final String status; // 'pending' -> 'preparing' -> 'delivering' -> 'completed' -> 'cancelled'
  final String shippingAddress;
  final String recipientName;
  final String recipientPhone;
  final String paymentMethod; // 'cod', 'momo', 'zalopay', 'credit_card'
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.shippingFee = 0.0,
    required this.totalAmount,
    this.deliveryType = 'delivery',
    this.status = 'pending',
    this.shippingAddress = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.paymentMethod = 'cod',
    this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawItems = map['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      items: rawItems
          .map((i) => OrderItemModel.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (map['shippingFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryType: map['deliveryType'] as String? ?? 'delivery',
      status: map['status'] as String? ?? 'pending',
      shippingAddress: map['shippingAddress'] as String? ?? '',
      recipientName: map['recipientName'] as String? ?? '',
      recipientPhone: map['recipientPhone'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? 'cod',
      createdAt: parseTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'deliveryType': deliveryType,
      'status': status,
      'shippingAddress': shippingAddress,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
