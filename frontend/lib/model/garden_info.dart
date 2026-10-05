class GardenInfo {
  const GardenInfo({
    required this.id,
    required this.name,
    required this.role,
    required this.members,
    this.invitationCode,
  });
  final int id;
  final String name;
  final String role;
  final int members;
  final String? invitationCode;
  bool get canWrite =>
      const ['Owner', 'Manager', 'Editor', 'Member'].contains(role);
}
