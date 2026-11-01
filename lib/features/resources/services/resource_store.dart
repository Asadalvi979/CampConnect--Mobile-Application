import 'package:flutter/foundation.dart';

import '../../profile/models/user_profile.dart';
import '../data/resource_mock_data.dart';
import '../models/resource.dart';
import '../models/resource_report.dart';

enum ResourceUploadResult { created, invalidRole, invalidMetadata, invalidFile }

enum ResourceReportResult { submitted, duplicate, unavailable }

enum ResourceModerationResult { updated, unauthorized, unavailable }

enum ResourceDownloadResult { previewAllowed, unavailable }

class ResourceStore extends ChangeNotifier {
  ResourceStore._()
    : _resources = List.of(ResourceMockData.initialResources),
      _reports = List.of(ResourceMockData.initialReports);

  static final ResourceStore instance = ResourceStore._();

  final List<AcademicResource> _resources;
  final List<ResourceReport> _reports;
  int _nextResourceNumber = 1;
  int _nextReportNumber = 1;

  List<AcademicResource> get resources => List.unmodifiable(_resources);
  List<ResourceReport> get reports => List.unmodifiable(_reports);

  void resetMockData() {
    _resources
      ..clear()
      ..addAll(ResourceMockData.initialResources);
    _reports
      ..clear()
      ..addAll(ResourceMockData.initialReports);
    _nextResourceNumber = 1;
    _nextReportNumber = 1;
    notifyListeners();
  }

  String currentUserId(UserProfileRole role) => switch (role) {
    UserProfileRole.student => 'current-student',
    UserProfileRole.senior => 'current-senior',
    UserProfileRole.alumni => 'mentor-bilal',
    UserProfileRole.admin => 'current-admin',
  };

  String uploaderName(
    String uploaderId, {
    required UserProfileRole viewerRole,
  }) {
    final profile = UserProfileStore.instance.profile.value;
    if (uploaderId == currentUserId(viewerRole) && profile.role == viewerRole) {
      return profile.name;
    }
    return ResourceMockData.mockUsers[uploaderId]?.$1 ?? 'Campus contributor';
  }

  UserProfileRole mockUploaderRole(String uploaderId) =>
      ResourceMockData.mockUsers[uploaderId]?.$2 ?? UserProfileRole.student;

  AcademicResource? resourceById(String id) {
    for (final resource in _resources) {
      if (resource.id == id) return resource;
    }
    return null;
  }

  List<AcademicResource> publishedResources() =>
      _resources
          .where((resource) => resource.status == ResourceStatus.published)
          .toList()
        ..sort(
          (first, second) => second.uploadedAt.compareTo(first.uploadedAt),
        );

  List<AcademicResource> resourcesForUploader(String uploaderId) =>
      _resources.where((resource) => resource.uploaderId == uploaderId).toList()
        ..sort(
          (first, second) => second.uploadedAt.compareTo(first.uploadedAt),
        );

  List<ResourceReport> openReports() =>
      _reports.where((report) => !report.isReviewed).toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<ResourceReport> reportsForResource(String resourceId) =>
      _reports.where((report) => report.resourceId == resourceId).toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  ResourceReport? reportById(String id) {
    for (final report in _reports) {
      if (report.id == id) return report;
    }
    return null;
  }

  ResourceUploadResult uploadResource({
    required UserProfileRole uploaderRole,
    required String uploaderId,
    required String title,
    required String description,
    required ResourceCategory category,
    required String subject,
    required String department,
    required int? semester,
    required String academicYear,
    required MockResourceFile? file,
  }) {
    if (uploaderRole == UserProfileRole.admin ||
        uploaderId != currentUserId(uploaderRole)) {
      return ResourceUploadResult.invalidRole;
    }
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();
    if (trimmedTitle.isEmpty ||
        trimmedTitle.length > 100 ||
        trimmedDescription.isEmpty ||
        trimmedDescription.length > 500 ||
        subject.trim().isEmpty ||
        department.trim().isEmpty) {
      return ResourceUploadResult.invalidMetadata;
    }
    if (file == null || !_isSupportedFile(file)) {
      return ResourceUploadResult.invalidFile;
    }

    _resources.add(
      AcademicResource(
        id: 'resource-local-${_nextResourceNumber++}',
        uploaderId: uploaderId,
        title: trimmedTitle,
        description: trimmedDescription,
        category: category,
        fileName: file.name,
        fileUrl: 'mock://${file.name}',
        fileType: file.fileType,
        fileSizeKb: file.sizeKb,
        subject: subject.trim(),
        department: department.trim(),
        semester: semester,
        academicYear: academicYear.trim(),
        status: ResourceStatus.published,
        uploadedAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return ResourceUploadResult.created;
  }

  ResourceReportResult reportResource({
    required String resourceId,
    required String reporterId,
    required UserProfileRole reporterRole,
    required ResourceReportReason reason,
    required String details,
  }) {
    final resource = resourceById(resourceId);
    if (reporterRole == UserProfileRole.admin ||
        reporterId != currentUserId(reporterRole) ||
        resource == null ||
        resource.status != ResourceStatus.published) {
      return ResourceReportResult.unavailable;
    }
    if (_reports.any(
      (report) =>
          report.resourceId == resourceId && report.reporterId == reporterId,
    )) {
      return ResourceReportResult.duplicate;
    }
    _reports.add(
      ResourceReport(
        id: 'resource-report-local-${_nextReportNumber++}',
        resourceId: resourceId,
        reporterId: reporterId,
        reason: reason,
        details: details.trim().isEmpty ? null : details.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return ResourceReportResult.submitted;
  }

  ResourceModerationResult moderateReport({
    required String reportId,
    required UserProfileRole moderatorRole,
    required String moderatorId,
    required ResourceModerationDecision decision,
  }) {
    if (moderatorRole != UserProfileRole.admin ||
        moderatorId != currentUserId(UserProfileRole.admin)) {
      return ResourceModerationResult.unauthorized;
    }
    final reportIndex = _reports.indexWhere((report) => report.id == reportId);
    if (reportIndex < 0 || _reports[reportIndex].isReviewed) {
      return ResourceModerationResult.unavailable;
    }
    final resourceIndex = _resources.indexWhere(
      (resource) => resource.id == _reports[reportIndex].resourceId,
    );
    if (resourceIndex < 0) return ResourceModerationResult.unavailable;

    final resolvedAt = DateTime.now();
    final status = switch (decision) {
      ResourceModerationDecision.keepPublished => ResourceStatus.published,
      ResourceModerationDecision.restrict => ResourceStatus.restricted,
      ResourceModerationDecision.remove => ResourceStatus.removed,
    };
    _resources[resourceIndex] = _resources[resourceIndex].copyWith(
      status: status,
    );
    _reports[reportIndex] = _reports[reportIndex].resolve(
      decision: decision,
      adminId: moderatorId,
      resolvedAt: resolvedAt,
    );
    notifyListeners();
    return ResourceModerationResult.updated;
  }

  ResourceDownloadResult requestDownload(String resourceId) {
    final resource = resourceById(resourceId);
    return resource?.status == ResourceStatus.published
        ? ResourceDownloadResult.previewAllowed
        : ResourceDownloadResult.unavailable;
  }

  static bool _isSupportedFile(MockResourceFile file) {
    const extensions = {'pdf', 'docx', 'pptx', 'zip'};
    return extensions.contains(file.extension) &&
        file.sizeKb > 0 &&
        file.sizeKb <= 25 * 1024;
  }
}
