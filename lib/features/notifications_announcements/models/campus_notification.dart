class CampusNotification {
  const CampusNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final int notificationId;
  final String userId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  CampusNotification copyWith({bool? isRead}) => CampusNotification(
    notificationId: notificationId,
    userId: userId,
    type: type,
    message: message,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
