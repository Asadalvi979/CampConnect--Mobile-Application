class ConversationParticipant {
  const ConversationParticipant({
    required this.conversationId,
    required this.userId,
    required this.joinedAt,
  });

  final String conversationId;
  final String userId;
  final DateTime joinedAt;
}
