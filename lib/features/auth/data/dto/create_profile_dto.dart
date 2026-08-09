class CreateProfileDto {
  const CreateProfileDto({required this.systemRoleId});

  final String systemRoleId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'system_role_id': systemRoleId};
  }
}
