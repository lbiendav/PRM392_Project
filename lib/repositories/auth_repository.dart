import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream theo dõi trạng thái xác thực của người dùng (null: chưa đăng nhập)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Thông tin User hiện tại từ Firebase Auth
  User? get currentUser => _firebaseAuth.currentUser;

  /// Đăng ký tài khoản mới bằng Email và Mật khẩu
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định khi đăng ký: $e';
    }
  }

  /// Đăng nhập bằng Email và Mật khẩu
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định khi đăng nhập: $e';
    }
  }

  /// Đăng nhập bằng Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Kích hoạt luồng đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng tự hủy đăng nhập
        return null;
      }

      // 2. Lấy thông tin xác thực (token) từ yêu cầu
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Tạo credential mới cho Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase với credential Google
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đăng nhập Google thất bại: $e';
    }
  }

  /// Gửi email đặt lại mật khẩu (Forgot Password)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Không thể gửi email đặt lại mật khẩu: $e';
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Lỗi khi đăng xuất: $e';
    }
  }

  /// Chuyển đổi mã lỗi FirebaseAuthException sang thông báo tiếng Việt thân thiện
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Tài khoản hoặc mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi một tài khoản khác.';
      case 'invalid-email':
        return 'Địa chỉ email không đúng định dạng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu phức tạp hơn.';
      case 'user-disabled':
        return 'Tài khoản này đã bị khóa hoặc vô hiệu hóa.';
      case 'too-many-requests':
        return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau vài phút.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại Wifi/4G của bạn.';
      default:
        return e.message ?? 'Đã xảy ra lỗi xác thực (${e.code}).';
    }
  }
}
