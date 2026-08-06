class RefreshTokenDto {
  const RefreshTokenDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'refresh_token': refreshToken};
  }
}
