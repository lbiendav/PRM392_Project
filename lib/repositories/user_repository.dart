import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection(AppConstants.colUsers);

  /// Tạo mới hồ sơ người dùng trong Firestore khi vừa đăng ký thành công
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCol.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw 'Không thể khởi tạo thông tin người dùng: $e';
    }
  }

  /// Lấy thông tin hồ sơ của người dùng theo UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromSnapshot(doc);
    } catch (e) {
      throw 'Không thể tải thông tin cá nhân: $e';
    }
  }

  /// Lắng nghe thay đổi hồ sơ người dùng thời gian thực (Real-time Stream)
  Stream<UserModel?> watchUserProfile(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromSnapshot(doc);
    });
  }

  /// Cập nhật thông tin hồ sơ người dùng (Họ tên, SĐT, ngày sinh, avatar,...)
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _usersCol.doc(user.id).update(user.toMap());
    } catch (e) {
      throw 'Không thể cập nhật thông tin cá nhân: $e';
    }
  }

  /// Cập nhật các trường cụ thể (Partial Update)
  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCol.doc(uid).update(data);
    } catch (e) {
      throw 'Không thể cập nhật dữ liệu: $e';
    }
  }

  /// Upload ảnh đại diện từ File máy cục bộ lên Firebase Storage và trả về URL công khai
  Future<String> uploadAvatarImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      // Đặt tên file: avatars/{uid}.jpg
      final ref = _storage
          .ref()
          .child(AppConstants.storageAvatars)
          .child('$uid.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': uid},
      );

      // Upload file lên Firebase Storage
      final uploadTask = await ref.putFile(imageFile, metadata);

      // Lấy đường dẫn tải xuống (Download URL)
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Lỗi khi tải ảnh đại diện lên Firebase Storage: $e';
    }
  }
}
