enum AnnouncementStatus { published }

class CampusAnnouncement {
  const CampusAnnouncement({
    required this.announcementId,
    required this.adminId,
    required this.title,
    required this.content,
    required this.status,
    required this.publishedAt,
  });

  final int announcementId;
  final String adminId;
  final String title;
  final String content;
  final AnnouncementStatus status;
  final DateTime publishedAt;
}
