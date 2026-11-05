import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? photoUrl;
  final String? dateOfBirth; // Format: dd/MM/yyyy
  final int loyaltyPoints; // Điểm tích lũy cho Module Thành viên 5
  final String role; // 'customer' | 'admin'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber = '',
    this.photoUrl,
    this.dateOfBirth,
    this.loyaltyPoints = 0,
    this.role = 'customer',
    this.createdAt,
    this.updatedAt,
  });

  /// Chuyển đổi từ Map / Firestore document data sang UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return UserModel(
      id: documentId,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      loyaltyPoints: (map['loyaltyPoints'] as num?)?.toInt() ?? 0,
      role: map['role'] as String? ?? 'customer',
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }

  /// Chuyển đổi từ Firestore DocumentSnapshot sang UserModel
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  /// Chuyển đổi UserModel object sang Map để ghi vào Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth,
      'loyaltyPoints': loyaltyPoints,
      'role': role,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Sao chép đối tượng với các trường được cập nhật (immutable pattern)
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
    String? dateOfBirth,
    int? loyaltyPoints,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, points: $loyaltyPoints)';
  }
}
