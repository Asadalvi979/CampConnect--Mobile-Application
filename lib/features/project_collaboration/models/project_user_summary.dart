import '../../profile/models/user_profile.dart';

class ProjectUserSummary {
  const ProjectUserSummary({
    required this.id,
    required this.name,
    required this.role,
    required this.program,
    required this.semester,
    required this.university,
    required this.department,
    required this.location,
    required this.cgpa,
    required this.skills,
  });

  final String id;
  final String name;
  final UserProfileRole role;
  final String program;
  final String semester;
  final String university;
  final String department;
  final String location;
  final String cgpa;
  final List<String> skills;

  String get roleLabel => switch (role) {
    UserProfileRole.student => 'Student',
    UserProfileRole.senior => 'Senior',
    UserProfileRole.alumni => 'Alumni',
    UserProfileRole.admin => 'Admin',
  };
}
