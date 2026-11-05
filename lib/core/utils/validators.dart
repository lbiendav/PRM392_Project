class AppValidators {
  AppValidators._();

  /// Kiểm tra định dạng Email chuẩn quốc tế bằng Regular Expression
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ (Ví dụ: coffee@domain.com)';
    }
    return null;
  }

  /// Kiểm tra độ mạnh của mật khẩu:
  /// - Tối thiểu 6 ký tự
  /// - Chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có tối thiểu 6 ký tự';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ hoa (A-Z)';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ thường (a-z)';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số (0-9)';
    }
    return null;
  }

  /// Kiểm tra xác nhận mật khẩu có khớp hay không
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận lại mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  /// Kiểm tra họ và tên (không được để trống, tối thiểu 2 ký tự)
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên của bạn';
    }
    if (value.trim().length < 2) {
      return 'Họ tên quá ngắn';
    }
    return null;
  }

  /// Kiểm tra số điện thoại Việt Nam (10 số, bắt đầu bằng 03, 05, 07, 08, 09 hoặc 84)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Số điện thoại không hợp lệ (10 chữ số)';
    }
    return null;
  }
}
