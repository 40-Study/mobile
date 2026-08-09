class SwitchRoleDto {
  const SwitchRoleDto({
    required this.roleId,
    required this.roleType,
    this.organizationId,
  });

  final String roleId;
  final String roleType;
  final String? organizationId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'role_id': roleId,
      'role_type': roleType,
      if (organizationId != null) 'organization_id': organizationId,
    };
  }
}
