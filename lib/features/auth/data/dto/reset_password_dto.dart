class ResetPasswordDto {
  const ResetPasswordDto({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'otp': otp,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}
