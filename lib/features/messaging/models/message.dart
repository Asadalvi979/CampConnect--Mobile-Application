class MessagingMessage {
  const MessagingMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sentAt,
    this.content,
    this.readAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final DateTime sentAt;
  final DateTime? readAt;
}
