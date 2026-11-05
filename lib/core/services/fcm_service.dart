import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Khởi tạo FCM: Yêu cầu quyền và lắng nghe thông báo
  Future<void> initialize() async {
    try {
      // 1. Yêu cầu quyền nhận thông báo (đặc biệt quan trọng trên iOS/macOS/Android 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      // 2. Lấy FCM Device Token (dùng để gửi thông báo đến máy này)
      // ignore: deprecated_member_use
      String? token = await _messaging.getToken();
      debugPrint('FCM Device Token: $token');

      // 3. Xử lý nhận thông báo khi app đang chạy Foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.notification?.title}');
      });

      // 4. Xử lý khi người dùng chạm vào thông báo mở app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Notification clicked: ${message.data}');
      });
    } catch (e) {
      debugPrint('Lỗi khởi tạo FCM: $e');
    }
  }

  /// Lấy FCM Token của thiết bị hiện tại
  Future<String?> getToken() async {
    try {
      // ignore: deprecated_member_use
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Không thể lấy FCM token: $e');
      return null;
    }
  }
}
