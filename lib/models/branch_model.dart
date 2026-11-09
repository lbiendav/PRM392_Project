class BranchModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final int openMinute;
  final int closeMinute;
  final bool isActive;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone = '',
    this.openMinute = 420,
    this.closeMinute = 1380,
    this.isActive = true,
  });

  factory BranchModel.fromMap(Map<String, dynamic> map, String id) {
    return BranchModel(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      openMinute: (map['openMinute'] as num?)?.toInt() ?? 420,
      closeMinute: (map['closeMinute'] as num?)?.toInt() ?? 1380,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  bool isOpenAt(DateTime time) {
    if (!isActive ||
        openMinute < 0 ||
        openMinute >= 1440 ||
        closeMinute < 0 ||
        closeMinute >= 1440) {
      return false;
    }
    final minute = time.hour * 60 + time.minute;
    if (openMinute == closeMinute) return true;
    if (openMinute < closeMinute) {
      return minute >= openMinute && minute < closeMinute;
    }
    return minute >= openMinute || minute < closeMinute;
  }

  String get hours => openMinute == closeMinute
      ? 'Mở cửa 24 giờ'
      : '${_format(openMinute)} - ${_format(closeMinute)}';

  String _format(int value) =>
      '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}';
}
