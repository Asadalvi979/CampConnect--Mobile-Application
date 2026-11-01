enum ResourceReportReason {
  copyrightConcern,
  inappropriateContent,
  misleadingInformation,
  spamOrDuplicate,
  unsafeFile,
  other;

  String get label => switch (this) {
    ResourceReportReason.copyrightConcern => 'Copyright Concern',
    ResourceReportReason.inappropriateContent => 'Inappropriate Content',
    ResourceReportReason.misleadingInformation =>
      'Incorrect or Misleading Information',
    ResourceReportReason.spamOrDuplicate => 'Spam or Duplicate Resource',
    ResourceReportReason.unsafeFile => 'Malicious or Unsafe File',
    ResourceReportReason.other => 'Other',
  };
}

enum ResourceModerationDecision { keepPublished, restrict, remove }

class ResourceReport {
  const ResourceReport({
    required this.id,
    required this.resourceId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
    this.details,
    this.resolution,
    this.resolvedBy,
    this.resolvedAt,
  });

  final String id;
  final String resourceId;
  final String reporterId;
  final ResourceReportReason reason;
  final String? details;
  final DateTime createdAt;
  final ResourceModerationDecision? resolution;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  bool get isReviewed => resolvedAt != null;

  ResourceReport resolve({
    required ResourceModerationDecision decision,
    required String adminId,
    required DateTime resolvedAt,
  }) => ResourceReport(
    id: id,
    resourceId: resourceId,
    reporterId: reporterId,
    reason: reason,
    details: details,
    createdAt: createdAt,
    resolution: decision,
    resolvedBy: adminId,
    resolvedAt: resolvedAt,
  );
}
