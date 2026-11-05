class AddressModel {
  final String id;
  final String userId;
  final String label; // 'Nhà riêng', 'Văn phòng', 'Khác'
  final String fullAddress;
  final String recipientName;
  final String recipientPhone;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.isDefault = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map, String id) {
    return AddressModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      label: map['label'] as String? ?? 'Nhà riêng',
      fullAddress: map['fullAddress'] as String? ?? '',
      recipientName: map['recipientName'] as String? ?? '',
      recipientPhone: map['recipientPhone'] as String? ?? '',
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'label': label,
      'fullAddress': fullAddress,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'isDefault': isDefault,
    };
  }
}
