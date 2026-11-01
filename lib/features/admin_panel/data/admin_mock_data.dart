import '../models/admin_user.dart';
import '../../profile/models/user_profile.dart';

abstract final class AdminMockData {
  static final users = <AdminUser>[
    AdminUser(
      id: 'mock-user-001',
      name: 'Areeba Khan',
      email: 'areeba.khan@campconnect.example',
      cmsId: 'CC-2022-BSSE-042',
      role: UserProfileRole.student,
      program: 'BS Software Engineering · 5th Semester',
      department: 'Faculty of Computing & Information Technology',
      joinedAt: DateTime(2023, 10, 12),
      accountStatus: AdminAccountStatus.active,
    ),
    AdminUser(
      id: 'mock-user-002',
      name: 'Zainab Farooq',
      email: 'zainab.farooq@campconnect.example',
      cmsId: 'CC-2021-BSSE-018',
      role: UserProfileRole.senior,
      program: 'BS Software Engineering · 8th Semester',
      department: 'Faculty of Computing & Information Technology',
      joinedAt: DateTime(2022, 9, 3),
      accountStatus: AdminAccountStatus.active,
    ),
    AdminUser(
      id: 'mock-user-003',
      name: 'Bilal Ahmed',
      email: 'bilal.ahmed@campconnect.example',
      cmsId: 'CC-2019-BSSE-011',
      role: UserProfileRole.alumni,
      program: 'BS Software Engineering · Alumni',
      department: 'Faculty of Computing & Information Technology',
      joinedAt: DateTime(2021, 6, 18),
      accountStatus: AdminAccountStatus.active,
    ),
    AdminUser(
      id: 'mock-user-004',
      name: 'Hamza Tariq',
      email: 'hamza.tariq@campconnect.example',
      cmsId: 'CC-2020-BSCS-026',
      role: UserProfileRole.senior,
      program: 'BS Computer Science · 7th Semester',
      department: 'Department of Computer Science',
      joinedAt: DateTime(2021, 8, 29),
      accountStatus: AdminAccountStatus.suspended,
    ),
    AdminUser(
      id: 'mock-user-005',
      name: 'Hira Naveed',
      email: 'hira.naveed@campconnect.example',
      cmsId: 'CC-2022-BSCS-039',
      role: UserProfileRole.student,
      program: 'BS Computer Science · 5th Semester',
      department: 'Department of Computer Science',
      joinedAt: DateTime(2023, 10, 15),
      accountStatus: AdminAccountStatus.active,
    ),
    AdminUser(
      id: 'mock-user-006',
      name: 'Danish Rehman',
      email: 'danish.rehman@campconnect.example',
      cmsId: 'CC-2021-BSSE-033',
      role: UserProfileRole.student,
      program: 'BS Software Engineering · 6th Semester',
      department: 'Faculty of Computing & Information Technology',
      joinedAt: DateTime(2022, 9, 7),
      accountStatus: AdminAccountStatus.active,
    ),
    AdminUser(
      id: 'mock-user-007',
      name: 'Ayesha Malik',
      email: 'ayesha.malik@campconnect.example',
      cmsId: 'CC-2018-BSCS-009',
      role: UserProfileRole.alumni,
      program: 'BS Computer Science · Alumni',
      department: 'Department of Computer Science',
      joinedAt: DateTime(2020, 7, 11),
      accountStatus: AdminAccountStatus.active,
    ),
  ];

  static final initialActivity = <AdminActivity>[
    AdminActivity(
      description: 'Resource submitted for review',
      context: 'Resource moderation · Computer Science',
      occurredAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AdminActivity(
      description: 'Campus announcement published',
      context: 'Announcements · Campus-wide visibility',
      occurredAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AdminActivity(
      description: 'Resource report received',
      context: 'Resource moderation · Report queue',
      occurredAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
