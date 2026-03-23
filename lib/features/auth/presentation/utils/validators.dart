/// Centralized form validators for auth screens.
class AuthValidators {
  const AuthValidators._();

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validates password (min 8 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu tối thiểu 8 ký tự';
    }
    return null;
  }

  /// Validates password confirmation.
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value != password) {
        return 'Mật khẩu không khớp';
      }
      return null;
    };
  }

  /// Validates username (min 3 characters, alphanumeric).
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    if (value.trim().length < 3) {
      return 'Tên đăng nhập tối thiểu 3 ký tự';
    }
    return null;
  }

  /// Validates OTP (6 digits).
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Mã OTP phải có 6 chữ số';
    }
    return null;
  }

  /// Validates required field.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? 'thông tin'}';
    }
    return null;
  }
}
