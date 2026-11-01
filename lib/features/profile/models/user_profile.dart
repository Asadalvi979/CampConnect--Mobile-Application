import 'package:flutter/foundation.dart';

enum UserProfileRole { student, senior, alumni, admin }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.role,
    required this.program,
    required this.semester,
    required this.location,
    required this.bio,
    required this.email,
    required this.studentId,
    required this.university,
    required this.department,
    required this.academicSession,
    required this.cgpa,
    required this.skills,
    required this.interests,
  });

  final String name;
  final UserProfileRole role;
  final String program;
  final String semester;
  final String location;
  final String bio;
  final String email;
  final String studentId;
  final String university;
  final String department;
  final String academicSession;
  final String cgpa;
  final List<String> skills;
  final List<String> interests;

  UserProfile copyWith({
    String? name,
    UserProfileRole? role,
    String? program,
    String? semester,
    String? location,
    String? bio,
    String? email,
    String? studentId,
    String? university,
    String? department,
    String? academicSession,
    String? cgpa,
    List<String>? skills,
    List<String>? interests,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      program: program ?? this.program,
      semester: semester ?? this.semester,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      university: university ?? this.university,
      department: department ?? this.department,
      academicSession: academicSession ?? this.academicSession,
      cgpa: cgpa ?? this.cgpa,
      skills: List.unmodifiable(skills ?? this.skills),
      interests: List.unmodifiable(interests ?? this.interests),
    );
  }

  String get roleLabel => switch (role) {
    UserProfileRole.student => 'Student',
    UserProfileRole.senior => 'Senior',
    UserProfileRole.alumni => 'Alumni',
    UserProfileRole.admin => 'Admin',
  };
}

class UserProfileStore {
  UserProfileStore._();

  static final UserProfileStore instance = UserProfileStore._();

  final ValueNotifier<UserProfile> profile = ValueNotifier(
    const UserProfile(
      name: 'Asadullah Sadiq',
      role: UserProfileRole.student,
      program: 'BS Software Engineering (BSSE)',
      semester: '5th Semester',
      location: 'Sahiwal, Pakistan',
      bio: 'Software Engineering student passionate about building innovative software solutions, exploring AI technologies, and collaborating on meaningful campus projects.',
      email: 'asadullah.sadiq@riphah.edu.pk',
      studentId: 'RP-2022-BSSE-042',
      university: 'Riphah International University',
      department: 'Faculty of Computing & Information Technology',
      academicSession: '2022 – 2026',
      cgpa: '3.72',
      skills: [
        'Python',
        'C++',
        'Flutter',
        'Dart',
        'MySQL',
        'JavaScript',
        'HTML',
        'CSS',
        'Git',
        'GitHub',
      ],
      interests: [
        'Artificial Intelligence',
        'Mobile Development',
        'Web Development',
        'Software Engineering',
        'Open Source',
      ],
    ),
  );

  bool _profileEdited = false;

  void update(UserProfile updated) {
    profile.value = updated;
    _profileEdited = true;
  }

  void setRole(UserProfileRole role) {
    profile.value = profile.value.copyWith(role: role);
  }

  void initializeRoleFromDashboard(UserProfileRole role) {
    if (_profileEdited) return;
    setRole(role);
  }
}
