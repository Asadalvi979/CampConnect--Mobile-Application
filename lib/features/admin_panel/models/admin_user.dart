import '../../profile/models/user_profile.dart';

enum AdminAccountStatus { active, suspended }

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.cmsId,
    required this.role,
    required this.program,
    required this.department,
    required this.joinedAt,
    required this.accountStatus,
  });

  final String id;
  final String name;
  final String email;
  final String cmsId;
  final UserProfileRole role;
  final String program;
  final String department;
  final DateTime joinedAt;
  final AdminAccountStatus accountStatus;

  AdminUser copyWith({AdminAccountStatus? accountStatus}) => AdminUser(
    id: id,
    name: name,
    email: email,
    cmsId: cmsId,
    role: role,
    program: program,
    department: department,
    joinedAt: joinedAt,
    accountStatus: accountStatus ?? this.accountStatus,
  );
}

class AdminActivity {
  AdminActivity({
    required this.description,
    required this.context,
    required this.occurredAt,
  });

  final String description;
  final String context;
  final DateTime occurredAt;
}
