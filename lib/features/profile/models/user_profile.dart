import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../authentication/services/auth_services.dart';

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
    this.id,
    this.accountStatus = 'active',
    this.createdAt,
  });

  /// Supabase auth user id (`profiles.id`). Null for the hardcoded demo
  /// profile used in preview mode.
  final String? id;

  /// 'active' or 'suspended' (see the `profiles` table check constraint).
  final String accountStatus;

  final DateTime? createdAt;
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
    String? id,
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
    String? accountStatus,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
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
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Reads a row from Supabase (PostgREST). Column names are snake_case;
  /// enums are stored as their `.name` strings.
  factory UserProfile.fromSupabaseMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String?,
      name: map['full_name'] as String? ?? '',
      role: UserProfileRole.values.firstWhere(
        (role) => role.name == (map['role'] as String? ?? 'student'),
        orElse: () => UserProfileRole.student,
      ),
      program: map['program'] as String? ?? '',
      semester: map['semester'] as String? ?? '',
      location: map['location'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      email: map['email'] as String? ?? '',
      studentId: map['cms_id'] as String? ?? '',
      university: map['university'] as String? ?? '',
      department: map['department'] as String? ?? '',
      academicSession: map['academic_session'] as String? ?? '',
      cgpa: map['cgpa']?.toString() ?? '',
      skills: (map['skills'] as List?)
              ?.map((value) => value.toString())
              .toList() ??
          const [],
      interests: (map['interests'] as List?)
              ?.map((value) => value.toString())
              .toList() ??
          const [],
      accountStatus: map['account_status'] as String? ?? 'active',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }

  /// Serializes for Supabase (`profiles` table). Used for upserts.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': name,
      'role': role.name,
      'program': program,
      'semester': semester,
      'location': location,
      'bio': bio,
      'email': email,
      'cms_id': studentId,
      'university': university,
      'department': department,
      'academic_session': academicSession,
      'cgpa': cgpa,
      'skills': skills,
      'interests': interests,
      'account_status': accountStatus,
    };
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
      name: 'Muhammad Hamza',
      role: UserProfileRole.student,
      program: 'BS Software Engineering (BSSE)',
      semester: '5th Semester',
      location: 'Sahiwal, Pakistan',
      bio: 'Software Engineering student interested in mobile development, artificial intelligence, and collaborating on meaningful campus projects.',
      email: 'muhammad.hamza@example.com',
      studentId: 'DEMO-BSSE-001',
      university: 'Riphah International University',
      department: 'Faculty of Computing & Information Technology',
      academicSession: '2024 – 2028',
      cgpa: '3.50',
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

  /// Test seam: when set, [loadFromSupabase] calls this instead of the
  /// network, so widget tests can inject a fake profile without Supabase.
  /// Tests must reset it to null in tearDown.
  static Future<UserProfile?> Function(String userId, String email)?
  profileLoaderOverride;

  /// Fetches the signed-in user's `profiles` row from Supabase and replaces
  /// the current profile with it. Returns true on success, false when there
  /// is no session, Supabase is not configured, or the row cannot be read —
  /// in all those cases the existing (demo) profile is kept untouched.
  Future<bool> loadFromSupabase() async {
    final userId = AuthServices.current.currentUserId;
    if (userId == null) return false;
    final email = AuthServices.current.currentUserEmail ?? profile.value.email;
    try {
      final loader = profileLoaderOverride ?? _fetchProfileFromSupabase;
      final fetched = await loader(userId, email);
      if (fetched == null) return false;
      profile.value = fetched;
      // The loaded role is real — dashboard navigation must not overwrite it.
      _profileEdited = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reads the `profiles` row; creates a minimal one when the signup trigger
  /// did not (e.g. trigger disabled), then reads it back.
  static Future<UserProfile?> _fetchProfileFromSupabase(
    String userId,
    String email,
  ) async {
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      return null;
    }
    final client = Supabase.instance.client;
    final row = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row != null) return UserProfile.fromSupabaseMap(row);
    final metadata = client.auth.currentUser?.userMetadata;
    final fullName =
        metadata?['full_name'] as String? ?? email.split('@').first;
    await client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'cms_id': metadata?['cms_id'] as String?,
      'role': 'student',
    });
    final created = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return created == null ? null : UserProfile.fromSupabaseMap(created);
  }

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
