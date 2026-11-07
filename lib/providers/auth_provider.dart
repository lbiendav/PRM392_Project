import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/services/shared_prefs_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

// --- Repositories Providers ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// --- Auth State ---
class AuthState {
  final bool isLoading;
  final UserModel? userModel;
  final User? firebaseUser;
  final String? errorMessage;
  final bool hasSeenOnboarding;

  const AuthState({
    this.isLoading = false,
    this.userModel,
    this.firebaseUser,
    this.errorMessage,
    this.hasSeenOnboarding = false,
  });

  bool get isAuthenticated => firebaseUser != null;

  AuthState copyWith({
    bool? isLoading,
    UserModel? userModel,
    User? firebaseUser,
    String? errorMessage,
    bool? hasSeenOnboarding,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userModel: clearUser ? null : (userModel ?? this.userModel),
      firebaseUser: clearUser ? null : (firebaseUser ?? this.firebaseUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }
}

// --- Auth Notifier Provider ---
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepo: ref.watch(authRepositoryProvider),
    userRepo: ref.watch(userRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepo;
  final UserRepository userRepo;

  AuthNotifier({
    required this.authRepo,
    required this.userRepo,
  })  : super(const AuthState(isLoading: true)) {
    _initializeAuth();
  }

  /// Khởi tạo trạng thái ban đầu: kiểm tra Onboarding & Session đăng nhập
  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPrefsService.getInstance();
      final hasSeen = prefs.hasSeenOnboarding;
      final currentFirebaseUser = authRepo.currentUser;

      UserModel? userProfile;
      if (currentFirebaseUser != null) {
        userProfile = await userRepo.getUserProfile(currentFirebaseUser.uid);
      }

      state = state.copyWith(
        isLoading: false,
        hasSeenOnboarding: hasSeen,
        firebaseUser: currentFirebaseUser,
        userModel: userProfile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải phiên đăng nhập: $e',
      );
    }
  }

  /// Đánh dấu đã xem xong Onboarding
  Future<void> completeOnboarding() async {
    final prefs = await SharedPrefsService.getInstance();
    await prefs.setHasSeenOnboarding(true);
    state = state.copyWith(hasSeenOnboarding: true);
  }

  /// Đăng nhập bằng Email & Password
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await authRepo.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw 'Đăng nhập không thành công, vui lòng thử lại.';
      }

      // Lấy thông tin UserModel từ Firestore
      var profile = await userRepo.getUserProfile(firebaseUser.uid);

      // Lưu/Xóa thông tin đăng nhập trong SharedPreferences
      final prefs = await SharedPrefsService.getInstance();
      if (rememberMe) {
        await prefs.saveCredentials(email: email, password: password);
      } else {
        await prefs.clearSavedCredentials();
      }

      state = state.copyWith(
        isLoading: false,
        firebaseUser: firebaseUser,
        userModel: profile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Đăng nhập bằng Google
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await authRepo.signInWithGoogle();
      if (credential == null) {
        // Người dùng ấn hủy đăng nhập Google
        state = state.copyWith(isLoading: false);
        return false;
      }

      final firebaseUser = credential.user!;
      // Kiểm tra xem đã có document trên Firestore chưa, nếu chưa có thì tạo mới
      var profile = await userRepo.getUserProfile(firebaseUser.uid);
      if (profile == null) {
        profile = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: firebaseUser.displayName ?? 'Khách hàng CoffeeCraft',
          phoneNumber: firebaseUser.phoneNumber ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        await userRepo.createUserProfile(profile);
      }

      state = state.copyWith(
        isLoading: false,
        firebaseUser: firebaseUser,
        userModel: profile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Đăng ký tài khoản mới và lưu thông tin vào Firestore `users`
  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await authRepo.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw 'Đăng ký không thành công, vui lòng thử lại.';
      }

      // Cập nhật DisplayName trên Firebase Auth
      await firebaseUser.updateDisplayName(fullName);

      // Tạo UserModel và lưu vào Firestore
      final newUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        photoUrl: null,
        loyaltyPoints: 50, // Tặng 50 điểm chào mừng thành viên mới!
        role: 'customer',
        createdAt: DateTime.now(),
      );

      await userRepo.createUserProfile(newUser);

      state = state.copyWith(
        isLoading: false,
        firebaseUser: firebaseUser,
        userModel: newUser,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Gửi link reset mật khẩu qua email
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await authRepo.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Cập nhật hồ sơ người dùng (Edit Profile & Avatar)
  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? dateOfBirth,
    File? newAvatarFile,
  }) async {
    final currentUser = state.userModel;
    final firebaseUser = state.firebaseUser;
    if (currentUser == null || firebaseUser == null) {
      state = state.copyWith(errorMessage: 'Chưa có thông tin phiên làm việc.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      String? photoUrl = currentUser.photoUrl;

      // Nếu có chọn ảnh mới thì upload lên Firebase Storage
      if (newAvatarFile != null) {
        photoUrl = await userRepo.uploadAvatarImage(
          uid: currentUser.id,
          imageFile: newAvatarFile,
        );
        // Cập nhật photoUrl cho Firebase Auth user
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      // Cập nhật DisplayName nếu có đổi
      if (fullName != currentUser.fullName) {
        await firebaseUser.updateDisplayName(fullName);
      }

      // Tạo model cập nhật
      final updatedUser = currentUser.copyWith(
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        dateOfBirth: dateOfBirth,
        photoUrl: photoUrl,
        updatedAt: DateTime.now(),
      );

      // Ghi lên Cloud Firestore
      await userRepo.updateUserProfile(updatedUser);

      state = state.copyWith(isLoading: false, userModel: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await authRepo.signOut();
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Xóa lỗi hiển thị
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
