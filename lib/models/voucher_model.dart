import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discountType; // 'percentage' | 'fixed' | 'freeship'
  final double discountValue; // Ví dụ 20 (%) hoặc 30000 (đ)
  final double minOrderAmount;
  final double maxDiscount;
  final DateTime? expiryDate;
  final bool isActive;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    this.description = '',
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0.0,
    this.maxDiscount = 0.0,
    this.expiryDate,
    this.isActive = true,
  });

  factory VoucherModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return VoucherModel(
      id: id,
      code: map['code'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      discountType: map['discountType'] as String? ?? 'fixed',
      discountValue: (map['discountValue'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (map['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (map['maxDiscount'] as num?)?.toDouble() ?? 0.0,
      expiryDate: parseTimestamp(map['expiryDate']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderAmount': minOrderAmount,
      'maxDiscount': maxDiscount,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
    };
  }
}
