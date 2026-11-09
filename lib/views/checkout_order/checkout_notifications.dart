import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutNotifications {
  CheckoutNotifications(this.uid);

  final String uid;
  StreamSubscription<String>? _refresh;
  Future<void> _pending = Future.value();
  DocumentReference<Map<String, dynamic>>? _registration;
  bool _closed = false;

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> start() async {
    if (!supported) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (_closed ||
          settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      if (_closed) return;
      final devices = FirebaseFirestore.instance
          .collection('checkoutPushDevices')
          .doc(uid)
          .collection('devices');
      const key = 'checkout_push_installation';
      final id = prefs.getString(key) ?? devices.doc().id;
      await prefs.setString(key, id);
      if (_closed) return;
      _registration = devices.doc(id);
      // The project uses the token API available in its pinned Flutter plugin.
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (_closed) return;
      if (token != null) _save(token);
      // ignore: deprecated_member_use
      _refresh = messaging.onTokenRefresh.listen(
        _save,
        onError: (Object _) {
          debugPrint('Không thể làm mới đăng ký thông báo đơn hàng.');
        },
      );
    } catch (_) {
      debugPrint('Không thể khởi tạo thông báo đơn hàng.');
    }
  }

  void _save(String token) {
    _pending = _pending.then((_) async {
      if (_closed || FirebaseAuth.instance.currentUser?.uid != uid) return;
      try {
        await _registration?.set({'token': token});
      } catch (_) {
        debugPrint('Không thể lưu đăng ký thông báo đơn hàng.');
      }
    });
  }

  Future<void> close({bool unregister = false}) async {
    _closed = true;
    await _refresh?.cancel();
    if (!unregister || !supported) return;
    await _pending;
    try {
      await _registration?.delete();
    } catch (_) {
      // Invalidate this device token even if removing the document failed.
      // ignore: deprecated_member_use
      await FirebaseMessaging.instance.deleteToken();
    }
  }
}
