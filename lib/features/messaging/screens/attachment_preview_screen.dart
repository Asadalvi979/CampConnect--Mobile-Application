import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/messaging_route_arguments.dart';
import '../services/messaging_store.dart';
import '../widgets/messaging_widgets.dart';

class AttachmentPreviewScreen extends StatelessWidget {
  const AttachmentPreviewScreen({
    required this.viewerRole,
    required this.attachmentId,
    required this.isImage,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String attachmentId;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    final store = MessagingStore.instance;
    final attachment = store.attachments
        .where((item) => item.id == attachmentId)
        .firstOrNull;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final message =
        arguments is MessagingRouteArguments && arguments.messageId != null
        ? store.messageById(arguments.messageId!)
        : null;
    final authorized =
        arguments is MessagingRouteArguments &&
        arguments.conversationId != null &&
        message != null &&
        attachment?.messageId == message.id &&
        message.conversationId == arguments.conversationId &&
        store.isAuthorizedFor(
          arguments.conversationId!,
          store.currentUserId(viewerRole),
        );
    if (attachment == null || !authorized) {
      return MessagingPage(
        title: isImage ? 'Image preview' : 'File preview',
        child: const MessagingEmptyState(
          title: 'Attachment unavailable',
          message:
              'This item is missing or its conversation is not accessible.',
        ),
      );
    }
    return MessagingPage(
      title: isImage ? 'Image preview' : 'File preview',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(
                    isImage
                        ? Icons.image_outlined
                        : Icons.picture_as_pdf_outlined,
                    size: 82,
                    color: AppColors.deepPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              attachment.fileName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              '${attachment.fileType} · ${attachment.fileSizeKb} KB',
              style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
            const SizedBox(height: 9),
            const Text(
              'Local mock preview only. This file was not uploaded, downloaded, or saved.',
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

extension _AttachmentFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
