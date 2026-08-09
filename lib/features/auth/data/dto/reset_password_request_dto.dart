class ResetPasswordRequestDto {
  const ResetPasswordRequestDto({required this.email});

  final String email;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email};
  }
}
