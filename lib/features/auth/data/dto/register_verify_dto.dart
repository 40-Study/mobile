class RegisterVerifyDto {
  const RegisterVerifyDto({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'otp': otp};
  }
}
