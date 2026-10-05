import '../generated/protocol.dart';

enum DriveRole {
  owner('Owner'),
  manager('Manager'),
  editor('Editor'),
  viewer('Viewer');

  const DriveRole(this.label);
  final String label;

  static DriveRole parse(String value) => switch (value) {
    'Owner' => owner,
    'Manager' => manager,
    'Editor' || 'Member' => editor,
    'Viewer' => viewer,
    _ => throw GardenException(message: 'Invalid drive permission.'),
  };

  bool allows(DriveCapability capability) => switch (capability) {
    DriveCapability.read => true,
    DriveCapability.write => this != viewer,
    DriveCapability.manageMembers => this == owner || this == manager,
    DriveCapability.manageDrive => this == owner,
  };

  void require(DriveCapability capability) {
    if (!allows(capability)) {
      throw GardenException(
        message: 'Your drive permission does not allow this action.',
      );
    }
  }

  bool canManage(DriveRole target) =>
      target != owner &&
      (this == owner ||
          (this == manager && (target == editor || target == viewer)));
}

enum DriveCapability { read, write, manageMembers, manageDrive }
