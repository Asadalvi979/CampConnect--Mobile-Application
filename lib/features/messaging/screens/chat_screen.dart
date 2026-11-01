import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mentorship/services/mentorship_store.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/message.dart';
import '../models/message_attachment.dart';
import '../models/messaging_route_arguments.dart';
import '../services/messaging_store.dart';
import '../widgets/messaging_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.viewerRole,
    required this.conversationId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<MockAttachmentDraft> _drafts = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MessagingStore.instance;
    final viewerId = store.currentUserId(widget.viewerRole);
    return AnimatedBuilder(
      animation: Listenable.merge([store, MentorshipStore.instance]),
      builder: (context, _) {
        if (!store.isAuthorizedFor(widget.conversationId, viewerId)) {
          return MessagingPage(
            title: 'Conversation unavailable',
            child: const MessagingEmptyState(
              title: 'Messaging permission unavailable',
              message: 'This conversation requires an active friendship or accepted mentorship.',
            ),
          );
        }
        final peerId = store.peerIdFor(widget.conversationId, viewerId);
        if (peerId == null) {
          return MessagingPage(
            title: 'Conversation unavailable',
            child: const MessagingEmptyState(
              title: 'Conversation unavailable',
              message: 'The other participant could not be found.',
            ),
          );
        }
        final peer = store.contactFor(peerId);
        final messages = store.messagesFor(widget.conversationId);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                MessagingAvatar(contact: peer, radius: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        peer.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: [
                    Expanded(
                      child: messages.isEmpty
                          ? const MessagingEmptyState(
                              title: 'Start the conversation',
                              message: 'Send a message to get started.',
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                13,
                                14,
                                13,
                                12,
                              ),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return _messageBubble(
                                  context,
                                  store,
                                  message,
                                  isMine: message.senderId == viewerId,
                                  viewerRole: widget.viewerRole,
                                );
                              },
                            ),
                    ),
                    if (_drafts.isNotEmpty) _draftPreview(),
                    _composer(context, store, viewerId),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _messageBubble(
    BuildContext context,
    MessagingStore store,
    MessagingMessage message, {
    required bool isMine,
    required UserProfileRole viewerRole,
  }) {
    final attachments = store.attachmentsFor(message.id);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310),
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
          decoration: BoxDecoration(
            color: isMine ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isMine ? 15 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 15),
            ),
            border: isMine ? null : Border.all(color: AppColors.lightBlue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.content != null)
                Text(
                  message.content!,
                  style: TextStyle(
                    color: isMine ? AppColors.white : AppColors.primaryText,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              for (final attachment in attachments)
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: _attachmentTile(
                    context,
                    attachment,
                    isMine: isMine,
                    viewerRole: viewerRole,
                    messageId: message.id,
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    messagingTime(message.sentAt),
                    style: TextStyle(
                      color: isMine
                          ? AppColors.white.withValues(alpha: 0.75)
                          : AppColors.mutedText,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentTile(
    BuildContext context,
    MessageAttachment attachment, {
    required bool isMine,
    required UserProfileRole viewerRole,
    required String messageId,
  }) {
    final background = isMine
        ? AppColors.white.withValues(alpha: 0.15)
        : AppColors.paleBlue;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        attachment.isImage
            ? AppRoutes.messageImagePreview
            : AppRoutes.messageFilePreview,
        arguments: MessagingRouteArguments(
          viewerRole: viewerRole,
          conversationId: widget.conversationId,
          messageId: messageId,
          attachmentId: attachment.id,
        ),
      ),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              attachment.isImage
                  ? Icons.image_outlined
                  : Icons.insert_drive_file_outlined,
              color: isMine ? AppColors.white : AppColors.deepPrimary,
              size: 21,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isMine ? AppColors.white : AppColors.primaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${attachment.fileSizeKb} KB · Local mock',
                    style: TextStyle(
                      color: isMine
                          ? AppColors.white.withValues(alpha: 0.75)
                          : AppColors.mutedText,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _draftPreview() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
    color: AppColors.paleBlue,
    child: Wrap(
      spacing: 7,
      runSpacing: 5,
      children: [
        for (var i = 0; i < _drafts.length; i++)
          InputChip(
            avatar: Icon(
              _drafts[i].isImage
                  ? Icons.image_outlined
                  : Icons.insert_drive_file_outlined,
              size: 17,
            ),
            label: Text(_drafts[i].fileName),
            onDeleted: () => setState(() => _drafts.removeAt(i)),
          ),
      ],
    ),
  );

  Widget _composer(
    BuildContext context,
    MessagingStore store,
    String viewerId,
  ) => Padding(
    padding: EdgeInsets.fromLTRB(
      10,
      7,
      10,
      8 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Attach local mock file',
          onPressed: _showAttachmentOptions,
          icon: const Icon(Icons.attach_file, color: AppColors.deepPrimary),
        ),
        Expanded(
          child: TextField(
            controller: _messageController,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onSubmitted: (_) => _send(store, viewerId),
          ),
        ),
        const SizedBox(width: 6),
        IconButton.filled(
          tooltip: 'Send message',
          onPressed: () => _send(store, viewerId),
          icon: const Icon(Icons.send_rounded, size: 19),
        ),
      ],
    ),
  );

  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add local preview',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 7),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No file is selected or uploaded from your device.',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Mock image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(
                    () => _drafts.add(
                      const MockAttachmentDraft(
                        fileName: 'campus-project.jpg',
                        fileType: 'image/jpeg',
                        fileSizeKb: 428,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: const Text('Mock file'),
                onTap: () {
                  Navigator.pop(context);
                  setState(
                    () => _drafts.add(
                      const MockAttachmentDraft(
                        fileName: 'project-outline.pdf',
                        fileType: 'application/pdf',
                        fileSizeKb: 256,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _send(MessagingStore store, String viewerId) {
    final result = store.sendMessage(
      conversationId: widget.conversationId,
      senderId: viewerId,
      content: _messageController.text,
      attachments: List.of(_drafts),
    );
    if (result == MessageSendResult.empty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Enter a message or attach a mock file.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    if (result == MessageSendResult.unauthorized) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Messaging access is no longer available.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    _messageController.clear();
    setState(_drafts.clear);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
