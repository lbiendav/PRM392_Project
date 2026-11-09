import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItemModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'order', 'promo', 'system'
  final String? targetId; // orderId hoặc voucherId
  final bool isRead;
  final DateTime? createdAt;

  const NotificationItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'system',
    this.targetId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationItemModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return NotificationItemModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'system',
      targetId: map['targetId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: parseTimestamp(map['createdAt']),
    );
  }

  NotificationItemModel copyWith({bool? isRead}) {
    return NotificationItemModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      targetId: targetId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'targetId': targetId,
      'isRead': isRead,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
