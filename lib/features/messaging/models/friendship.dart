enum FriendshipStatus { active, removed }

class Friendship {
  const Friendship({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    required this.createdAt,
    this.endedAt,
  });

  final String id;
  final String user1Id;
  final String user2Id;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime? endedAt;

  bool connects(String first, String second) =>
      (user1Id == first && user2Id == second) ||
      (user1Id == second && user2Id == first);

  Friendship copyWith({FriendshipStatus? status, DateTime? endedAt}) =>
      Friendship(
        id: id,
        user1Id: user1Id,
        user2Id: user2Id,
        status: status ?? this.status,
        createdAt: createdAt,
        endedAt: endedAt ?? this.endedAt,
      );
}
