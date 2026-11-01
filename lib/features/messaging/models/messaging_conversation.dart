class MessagingConversation {
  const MessagingConversation({
    required this.id,
    required this.createdAt,
    this.friendshipId,
    this.mentorshipId,
  }) : assert((friendshipId == null) != (mentorshipId == null));

  final String id;
  final String? friendshipId;
  final String? mentorshipId;
  final DateTime createdAt;

  bool get isFriendshipConversation => friendshipId != null;
}
