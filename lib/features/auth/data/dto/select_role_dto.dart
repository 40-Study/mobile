class SelectRoleDto {
  const SelectRoleDto({
    required this.sessionToken,
    required this.roleId,
    required this.roleType,
    this.organizationId,
  });

  final String sessionToken;
  final String roleId;
  final String roleType;
  final String? organizationId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'session_token': sessionToken,
      'role_id': roleId,
      'role_type': roleType,
      if (organizationId != null) 'organization_id': organizationId,
    };
  }
}
