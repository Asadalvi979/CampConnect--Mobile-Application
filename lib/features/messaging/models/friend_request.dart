enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequest copyWith({
    FriendRequestStatus? status,
    DateTime? respondedAt,
  }) => FriendRequest(
    id: id,
    senderId: senderId,
    receiverId: receiverId,
    status: status ?? this.status,
    createdAt: createdAt,
    respondedAt: respondedAt ?? this.respondedAt,
  );
}
