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
}
