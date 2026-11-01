class MessageAttachment {
  const MessageAttachment({
    required this.id,
    required this.messageId,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSizeKb,
  });

  final String id;
  final String messageId;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSizeKb;

  bool get isImage => fileType.startsWith('image/');
}
