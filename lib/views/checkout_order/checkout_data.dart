import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../models/voucher_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/order_repository.dart';
import '../rewards_settings/voucher_wallet_screen.dart';

final checkoutUserIdProvider = Provider<String?>((ref) {
  return ref.watch(
    authNotifierProvider.select((state) => state.firebaseUser?.uid),
  );
});

final checkoutDataProvider = Provider<CheckoutData>((ref) {
  return CheckoutData(FirebaseFirestore.instance);
});

final checkoutAddressesProvider = StreamProvider.autoDispose
    .family<List<AddressModel>, String>((ref, uid) {
      return ref.watch(checkoutDataProvider).watchAddresses(uid);
    });

final checkoutOrdersProvider = StreamProvider.autoDispose
    .family<List<OrderModel>, String>((ref, uid) {
      return ref.watch(checkoutDataProvider).watchOrders(uid);
    });

final checkoutOrderProvider = StreamProvider.autoDispose
    .family<CheckoutOrderDetails?, String>((ref, id) {
      final uid = ref.watch(checkoutUserIdProvider);
      if (uid == null) return Stream.value(null);
      return ref.watch(checkoutDataProvider).watchOrder(uid, id);
    });

class CheckoutData {
  CheckoutData(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection(AppConstants.colOrders);

  // A single per-user document keeps address edits and the default atomic.
  DocumentReference<Map<String, dynamic>> _addressBook(String uid) =>
      _db.collection(AppConstants.colAddresses).doc(uid);

  List<AddressModel> _decodeAddresses(Map<String, dynamic>? data) {
    final addresses = data?['entries'] as List<dynamic>? ?? [];
    return [
      for (final entry in addresses.cast<Map<String, dynamic>>())
        AddressModel.fromMap(entry, entry['id'] as String),
    ];
  }

  Stream<List<AddressModel>> watchAddresses(String uid) {
    return _addressBook(
      uid,
    ).snapshots().map((doc) => _decodeAddresses(doc.data()));
  }

  Future<void> updateAddress(
    String uid, {
    AddressModel? address,
    String? removeId,
    String? defaultId,
  }) async {
    final book = _addressBook(uid);
    final selectedId = await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(book);
      final addresses = _decodeAddresses(snapshot.data());
      final currentDefault = addresses
          .where((item) => item.isDefault)
          .firstOrNull;
      if (removeId != null) {
        addresses.removeWhere((item) => item.id == removeId);
      }
      if (address != null) {
        final index = addresses.indexWhere((item) => item.id == address.id);
        if (index == -1) {
          addresses.add(address);
        } else {
          addresses[index] = address;
        }
      }

      final preferredId = defaultId ?? currentDefault?.id;
      final selected =
          addresses.where((item) => item.id == preferredId).firstOrNull ??
          addresses.firstOrNull;
      transaction.set(book, {
        'userId': uid,
        'entries': [
          for (final item in addresses)
            {
              ...item.toMap(),
              'id': item.id,
              'isDefault': item.id == selected?.id,
            },
        ],
      });
      return selected?.id;
    });
    final prefs = await SharedPreferences.getInstance();
    final key = 'checkout_default_address_$uid';
    if (selectedId == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, selectedId);
    }
  }

  String newAddressId(String uid) =>
      _addressBook(uid).collection('ids').doc().id;

  Future<VoucherModel?> findVoucher(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    try {
      final snapshot = await _db
          .collection(AppConstants.colVouchers)
          .where('code', isEqualTo: normalizedCode)
          .get();
      final vouchers = snapshot.docs.map(
        (doc) => VoucherModel.fromMap(doc.data(), doc.id),
      );
      final match = vouchers
          .where(
            (voucher) =>
                voucher.isActive &&
                (voucher.expiryDate?.isAfter(DateTime.now()) ?? true),
          )
          .firstOrNull;
      if (match != null) return match;
    } catch (_) {
      // Fallback to built-in wallet vouchers if Firestore lookup fails.
    }
    return buildDefaultWalletVouchers()
        .where(
          (voucher) =>
              voucher.code.toUpperCase() == normalizedCode &&
              voucher.isActive &&
              (voucher.expiryDate?.isAfter(DateTime.now()) ?? true),
        )
        .firstOrNull;
  }

  Future<String> createOrder(OrderModel order) =>
      OrderRepository(firestore: _db).createOrder(order);

  Stream<List<OrderModel>> watchOrders(String uid) {
    return _orders.where('userId', isEqualTo: uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList()
        ..sort(
          (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          ),
        );
    });
  }

  Stream<CheckoutOrderDetails?> watchOrder(String uid, String id) {
    return _orders.doc(id).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || data['userId'] != uid) return null;
      final order = OrderModel.fromMap(data, id);
      final prefix = order.deliveryType == 'pickup' ? 'store' : 'driver';
      return CheckoutOrderDetails(
        order: order,
        contactName: data['${prefix}Name'] as String?,
        contactPhone: data['${prefix}Phone'] as String?,
        driverPlate: data['driverPlate'] as String?,
        driverPhotoUrl: data['driverPhotoUrl'] as String?,
      );
    });
  }
}

class CheckoutOrderDetails {
  const CheckoutOrderDetails({
    required this.order,
    this.contactName,
    this.contactPhone,
    this.driverPlate,
    this.driverPhotoUrl,
  });

  final OrderModel order;
  final String? contactName;
  final String? contactPhone;
  final String? driverPlate;
  final String? driverPhotoUrl;
}

double checkoutDiscount(
  VoucherModel? voucher,
  double subtotal,
  double shippingFee,
) {
  if (voucher == null ||
      !voucher.isActive ||
      subtotal < voucher.minOrderAmount ||
      !(voucher.expiryDate?.isAfter(DateTime.now()) ?? true)) {
    return 0;
  }
  final amount = switch (voucher.discountType) {
    'fixed' => voucher.discountValue,
    'percentage' => subtotal * voucher.discountValue / 100,
    'freeship' => shippingFee,
    _ => 0.0,
  };
  final capped = voucher.maxDiscount > 0
      ? math.min(amount, voucher.maxDiscount)
      : amount;
  final eligibleTotal = voucher.discountType == 'freeship'
      ? shippingFee
      : subtotal;
  return math.max(0.0, math.min(capped, eligibleTotal)).roundToDouble();
}
