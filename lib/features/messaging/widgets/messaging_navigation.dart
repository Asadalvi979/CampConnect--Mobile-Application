import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/messaging_route_arguments.dart';
import '../services/messaging_store.dart';

void openMessageInbox(
  BuildContext context, {
  required UserProfileRole viewerRole,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.messages,
    arguments: MessagingRouteArguments(viewerRole: viewerRole),
  );
}

void openFriendConversation(
  BuildContext context, {
  required UserProfileRole viewerRole,
  required String peerId,
}) {
  final store = MessagingStore.instance;
  final conversation = store.openFriendConversation(
    viewerId: store.currentUserId(viewerRole),
    peerId: peerId,
  );
  if (conversation == null) {
    _showMessage(context, 'Messaging is available only for active friends.');
    return;
  }
  Navigator.of(context).pushNamed(
    AppRoutes.messageChat,
    arguments: MessagingRouteArguments(
      viewerRole: viewerRole,
      conversationId: conversation.id,
    ),
  );
}

void openMentorshipConversation(
  BuildContext context, {
  required UserProfileRole viewerRole,
  required String requestId,
}) {
  final store = MessagingStore.instance;
  final conversation = store.openMentorshipConversation(
    viewerId: store.currentUserId(viewerRole),
    requestId: requestId,
  );
  if (conversation == null) {
    _showMessage(context, 'Messaging requires an accepted mentorship.');
    return;
  }
  Navigator.of(context).pushNamed(
    AppRoutes.messageChat,
    arguments: MessagingRouteArguments(
      viewerRole: viewerRole,
      conversationId: conversation.id,
    ),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}
