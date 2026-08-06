class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userName,
    this.fullName,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String userName;
  final String? fullName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'user_name': userName,
      if (fullName != null && fullName!.isNotEmpty) 'full_name': fullName,
    };
  }
}
