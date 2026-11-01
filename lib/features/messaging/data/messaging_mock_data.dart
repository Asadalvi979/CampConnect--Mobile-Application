import '../../profile/models/user_profile.dart';
import '../models/friend_request.dart';
import '../models/friendship.dart';
import '../models/messaging_contact.dart';

abstract final class MessagingMockData {
  static const contacts = <String, MessagingContact>{
    'senior-zainab': MessagingContact(
      id: 'senior-zainab',
      name: 'Zainab Farooq',
      role: UserProfileRole.senior,
      headline: 'Senior · Software Engineering',
      program: 'BS Software Engineering',
      department: 'Faculty of Computing',
    ),
    'senior-hamza': MessagingContact(
      id: 'senior-hamza',
      name: 'Hamza Tariq',
      role: UserProfileRole.senior,
      headline: 'Senior · Computer Science',
      program: 'BS Computer Science',
      department: 'Faculty of Computing',
    ),
    'student-usman': MessagingContact(
      id: 'student-usman',
      name: 'Usman Ali',
      role: UserProfileRole.student,
      headline: 'Student · Software Engineering',
      program: 'BS Software Engineering',
      department: 'Faculty of Computing',
    ),
    'student-danish': MessagingContact(
      id: 'student-danish',
      name: 'Danish Rehman',
      role: UserProfileRole.student,
      headline: 'Student · Computer Science',
      program: 'BS Computer Science',
      department: 'Faculty of Computing',
    ),
    'senior-hira': MessagingContact(
      id: 'senior-hira',
      name: 'Hira Naveed',
      role: UserProfileRole.senior,
      headline: 'Senior · Information Technology',
      program: 'BS Information Technology',
      department: 'Faculty of Computing',
    ),
    'mentor-ayesha': MessagingContact(
      id: 'mentor-ayesha',
      name: 'Ayesha Khan',
      role: UserProfileRole.alumni,
      headline: 'Alumni · Product Designer',
      program: 'BS Software Engineering',
      department: 'Faculty of Computing',
    ),
    'mentor-bilal': MessagingContact(
      id: 'mentor-bilal',
      name: 'Bilal Ahmed',
      role: UserProfileRole.alumni,
      headline: 'Alumni · Software Engineer',
      program: 'BS Computer Science',
      department: 'Faculty of Computing',
    ),
    'current-student': MessagingContact(
      id: 'current-student',
      name: 'Asadullah Sadiq',
      role: UserProfileRole.student,
      headline: 'Student · Software Engineering',
      program: 'BS Software Engineering',
      department: 'Faculty of Computing',
    ),
    'current-senior': MessagingContact(
      id: 'current-senior',
      name: 'Zainab Farooq',
      role: UserProfileRole.senior,
      headline: 'Senior · Software Engineering',
      program: 'BS Software Engineering',
      department: 'Faculty of Computing',
    ),
    'current-admin': MessagingContact(
      id: 'current-admin',
      name: 'CampConnect Admin',
      role: UserProfileRole.admin,
      headline: 'Administrator',
      program: '',
      department: 'CampConnect',
    ),
  };

  static final initialFriendships = <Friendship>[
    Friendship(
      id: 'friendship-student-zainab',
      user1Id: 'current-student',
      user2Id: 'senior-zainab',
      status: FriendshipStatus.active,
      createdAt: DateTime(2025, 1, 15),
    ),
    Friendship(
      id: 'friendship-student-hamza',
      user1Id: 'current-student',
      user2Id: 'senior-hamza',
      status: FriendshipStatus.active,
      createdAt: DateTime(2025, 1, 18),
    ),
    Friendship(
      id: 'friendship-student-usman',
      user1Id: 'current-student',
      user2Id: 'student-usman',
      status: FriendshipStatus.active,
      createdAt: DateTime(2025, 1, 20),
    ),
    Friendship(
      id: 'friendship-senior-usman',
      user1Id: 'current-senior',
      user2Id: 'student-usman',
      status: FriendshipStatus.active,
      createdAt: DateTime(2025, 1, 22),
    ),
    Friendship(
      id: 'friendship-removed-hira',
      user1Id: 'current-student',
      user2Id: 'senior-hira',
      status: FriendshipStatus.removed,
      createdAt: DateTime(2025, 1, 10),
      endedAt: DateTime(2025, 2, 2),
    ),
  ];

  static final initialFriendRequests = <FriendRequest>[
    FriendRequest(
      id: 'friend-request-danish',
      senderId: 'student-danish',
      receiverId: 'current-student',
      status: FriendRequestStatus.pending,
      createdAt: DateTime(2025, 2, 12),
    ),
    FriendRequest(
      id: 'friend-request-hira',
      senderId: 'senior-hira',
      receiverId: 'current-student',
      status: FriendRequestStatus.pending,
      createdAt: DateTime(2025, 2, 11),
    ),
    FriendRequest(
      id: 'friend-request-sent',
      senderId: 'current-student',
      receiverId: 'student-danish',
      status: FriendRequestStatus.pending,
      createdAt: DateTime(2025, 2, 13),
    ),
  ];
}
