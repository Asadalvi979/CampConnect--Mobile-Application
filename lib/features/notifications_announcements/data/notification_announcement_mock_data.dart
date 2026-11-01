import '../models/announcement.dart';
import '../models/campus_notification.dart';

abstract final class NotificationAnnouncementMockData {
  static const _studentId = 'current-student';
  static const _seniorId = 'current-senior';
  static const _alumniId = 'mentor-bilal';

  static final initialNotifications = <CampusNotification>[
    CampusNotification(
      notificationId: 1,
      userId: _studentId,
      type: 'Message request',
      message: 'A campus member sent you a message request.',
      isRead: false,
      createdAt: DateTime(2026, 10, 30, 10, 20),
    ),
    CampusNotification(
      notificationId: 2,
      userId: _studentId,
      type: 'Mentorship',
      message: 'Your mentorship request was accepted.',
      isRead: false,
      createdAt: DateTime(2026, 10, 29, 15, 5),
    ),
    CampusNotification(
      notificationId: 3,
      userId: _studentId,
      type: 'Project application',
      message: 'There is an update to a project application.',
      isRead: true,
      createdAt: DateTime(2026, 10, 27, 9, 40),
    ),
    CampusNotification(
      notificationId: 4,
      userId: _studentId,
      type: 'Announcement',
      message: 'A new campus announcement is available.',
      isRead: true,
      createdAt: DateTime(2026, 10, 25, 12, 0),
    ),
    CampusNotification(
      notificationId: 5,
      userId: _seniorId,
      type: 'Mentorship',
      message: 'A mentorship request has been accepted.',
      isRead: false,
      createdAt: DateTime(2026, 10, 28, 11, 0),
    ),
    CampusNotification(
      notificationId: 6,
      userId: _alumniId,
      type: 'Message request',
      message: 'A campus member sent you a message request.',
      isRead: false,
      createdAt: DateTime(2026, 10, 26, 13, 30),
    ),
  ];

  static final initialAnnouncements = <CampusAnnouncement>[
    CampusAnnouncement(
      announcementId: 1,
      adminId: 'current-admin',
      title: 'Fall 2024 Capstone Project & FYP Proposals Open',
      content: 'The Department of Computing invites project synopsis submissions. Submit supervisor approval letters through the departmental academic portal before the announced deadline.',
      status: AnnouncementStatus.published,
      publishedAt: DateTime(2024, 10, 20),
    ),
    CampusAnnouncement(
      announcementId: 2,
      adminId: 'current-admin',
      title: 'Campus Mentorship Program Registration',
      content: 'Students and alumni can explore the campus mentorship program through the Mentorship section of CampConnect.',
      status: AnnouncementStatus.published,
      publishedAt: DateTime(2024, 10, 10),
    ),
    CampusAnnouncement(
      announcementId: 3,
      adminId: 'current-admin',
      title: 'Academic Resource Sharing Honor Code',
      content: 'Please follow academic integrity guidance when sharing learning materials with the campus community.',
      status: AnnouncementStatus.published,
      publishedAt: DateTime(2024, 10, 2),
    ),
  ];
}
