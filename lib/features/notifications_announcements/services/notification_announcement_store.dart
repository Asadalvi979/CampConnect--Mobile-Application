import 'package:flutter/foundation.dart';

import '../../profile/models/user_profile.dart';
import '../data/notification_announcement_mock_data.dart';
import '../models/announcement.dart';
import '../models/campus_notification.dart';

enum NotificationUpdateResult { updated, unavailable }

enum AnnouncementPublishResult { published, unauthorized, invalidInput }

class NotificationAnnouncementStore extends ChangeNotifier {
  NotificationAnnouncementStore._()
    : _notifications = List.of(
        NotificationAnnouncementMockData.initialNotifications,
      ),
      _announcements = List.of(
        NotificationAnnouncementMockData.initialAnnouncements,
      ),
      _nextAnnouncementId =
          NotificationAnnouncementMockData.initialAnnouncements.length + 1,
      _nextNotificationId =
          NotificationAnnouncementMockData.initialNotifications.length + 1;

  static final NotificationAnnouncementStore instance =
      NotificationAnnouncementStore._();

  final List<CampusNotification> _notifications;
  final List<CampusAnnouncement> _announcements;
  int _nextAnnouncementId;
  int _nextNotificationId;

  List<CampusNotification> get notifications =>
      List.unmodifiable(_notifications);
  List<CampusAnnouncement> get announcements =>
      List.unmodifiable(_announcements);

  String userIdFor(UserProfileRole role) => switch (role) {
    UserProfileRole.student => 'current-student',
    UserProfileRole.senior => 'current-senior',
    UserProfileRole.alumni => 'mentor-bilal',
    UserProfileRole.admin => 'current-admin',
  };

  void resetMockData() {
    _notifications
      ..clear()
      ..addAll(NotificationAnnouncementMockData.initialNotifications);
    _announcements
      ..clear()
      ..addAll(NotificationAnnouncementMockData.initialAnnouncements);
    _nextAnnouncementId =
        NotificationAnnouncementMockData.initialAnnouncements.length + 1;
    _nextNotificationId =
        NotificationAnnouncementMockData.initialNotifications.length + 1;
    notifyListeners();
  }

  List<CampusNotification> notificationsFor(String userId) =>
      _notifications
          .where((notification) => notification.userId == userId)
          .toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  int unreadCountFor(String userId) => _notifications
      .where(
        (notification) => notification.userId == userId && !notification.isRead,
      )
      .length;

  void addActivityNotification({
    required String recipientId,
    required String type,
    required String message,
  }) {
    _appendActivityNotification(
      recipientId: recipientId,
      type: type,
      message: message,
    );
    notifyListeners();
  }

  void _appendActivityNotification({
    required String recipientId,
    required String type,
    required String message,
  }) {
    _notifications.add(
      CampusNotification(
        notificationId: _nextNotificationId++,
        userId: recipientId,
        type: type,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  NotificationUpdateResult markAsRead({
    required int notificationId,
    required String userId,
  }) {
    final index = _notifications.indexWhere(
      (notification) =>
          notification.notificationId == notificationId &&
          notification.userId == userId,
    );
    if (index < 0) return NotificationUpdateResult.unavailable;
    if (_notifications[index].isRead) return NotificationUpdateResult.updated;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
    return NotificationUpdateResult.updated;
  }

  List<CampusAnnouncement> publishedAnnouncements() =>
      _announcements
          .where(
            (announcement) =>
                announcement.status == AnnouncementStatus.published,
          )
          .toList()
        ..sort(
          (first, second) => second.publishedAt.compareTo(first.publishedAt),
        );

  CampusAnnouncement? announcementById(int announcementId) {
    for (final announcement in _announcements) {
      if (announcement.announcementId == announcementId) return announcement;
    }
    return null;
  }

  AnnouncementPublishResult createAndPublishAnnouncement({
    required UserProfileRole role,
    required String adminId,
    required String title,
    required String content,
  }) {
    if (role != UserProfileRole.admin ||
        adminId != userIdFor(UserProfileRole.admin)) {
      return AnnouncementPublishResult.unauthorized;
    }
    final normalizedTitle = title.trim();
    final normalizedContent = content.trim();
    if (normalizedTitle.isEmpty ||
        normalizedTitle.length > 150 ||
        normalizedContent.isEmpty) {
      return AnnouncementPublishResult.invalidInput;
    }
    _announcements.add(
      CampusAnnouncement(
        announcementId: _nextAnnouncementId++,
        adminId: adminId,
        title: normalizedTitle,
        content: normalizedContent,
        status: AnnouncementStatus.published,
        publishedAt: DateTime.now(),
      ),
    );
    for (final recipientRole in [
      UserProfileRole.student,
      UserProfileRole.senior,
      UserProfileRole.alumni,
    ]) {
      _appendActivityNotification(
        recipientId: userIdFor(recipientRole),
        type: 'Announcement',
        message: 'A new announcement was published: $normalizedTitle',
      );
    }
    notifyListeners();
    return AnnouncementPublishResult.published;
  }
}
