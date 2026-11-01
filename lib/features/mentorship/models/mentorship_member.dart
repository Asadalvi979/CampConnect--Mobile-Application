import '../../profile/models/user_profile.dart';

class MentorshipMember {
  const MentorshipMember({
    required this.id,
    required this.name,
    required this.role,
    required this.program,
    required this.semester,
    required this.university,
    required this.location,
    required this.cgpa,
  });

  final String id;
  final String name;
  final UserProfileRole role;
  final String program;
  final String semester;
  final String university;
  final String location;
  final String cgpa;

  String get roleLabel => switch (role) {
    UserProfileRole.student => 'Student',
    UserProfileRole.senior => 'Senior',
    UserProfileRole.alumni => 'Alumni',
    UserProfileRole.admin => 'Admin',
  };
}
