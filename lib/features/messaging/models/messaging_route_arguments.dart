import '../../profile/models/user_profile.dart';

class MessagingRouteArguments {
  const MessagingRouteArguments({
    required this.viewerRole,
    this.conversationId,
    this.friendId,
    this.messageId,
    this.attachmentId,
  });

  final UserProfileRole viewerRole;
  final String? conversationId;
  final String? friendId;
  final String? messageId;
  final String? attachmentId;
}
