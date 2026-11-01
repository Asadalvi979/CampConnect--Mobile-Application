import '../../profile/models/user_profile.dart';

class MessagingContact {
  const MessagingContact({
    required this.id,
    required this.name,
    required this.role,
    required this.headline,
    required this.program,
    required this.department,
  });

  final String id;
  final String name;
  final UserProfileRole role;
  final String headline;
  final String program;
  final String department;

  String get roleLabel => switch (role) {
    UserProfileRole.student => 'Student',
    UserProfileRole.senior => 'Senior',
    UserProfileRole.alumni => 'Alumni',
    UserProfileRole.admin => 'Admin',
  };
}
