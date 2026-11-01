import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource.dart';
import '../services/resource_store.dart';
import '../widgets/resource_navigation.dart';
import '../widgets/resource_widgets.dart';

class ResourceDetailsScreen extends StatelessWidget {
  const ResourceDetailsScreen({
    required this.viewerRole,
    required this.resourceId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String resourceId;

  @override
  Widget build(BuildContext context) {
    final store = ResourceStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final resource = store.resourceById(resourceId);
        if (resource == null) {
          return ResourcePage(
            title: 'Resource Details',
            child: const ResourceEmptyState(
              title: 'Resource unavailable',
              message: 'This resource could not be found.',
            ),
          );
        }
        final uploader = store.uploaderName(
          resource.uploaderId,
          viewerRole: viewerRole,
        );
        return ResourcePage(
          title: 'Resource Details',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(17, 14, 17, 24),
            children: [
              Row(
                children: [
                  Expanded(child: ResourceStatusChip(resource.status)),
                  Text(
                    resource.fileType.split('/').last.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                resource.title,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resource.description ?? 'No description provided.',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _uploaderCard(resource, uploader),
              const SizedBox(height: 14),
              _documentPreview(resource),
              const SizedBox(height: 14),
              _metadataCard(resource),
              const SizedBox(height: 14),
              if (resource.status == ResourceStatus.published)
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _download(context, store, resource),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(
                      'Download Resource (${resource.fileSizeLabel})',
                    ),
                  ),
                )
              else
                _downloadUnavailable(resource.status),
              if (resource.status == ResourceStatus.published &&
                  viewerRole != UserProfileRole.admin) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => openResourceReport(
                    context,
                    resourceId: resource.id,
                    viewerRole: viewerRole,
                  ),
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Report Resource'),
                ),
              ],
              const SizedBox(height: 9),
              const Text(
                'This is a local metadata preview. No document is actually opened, downloaded, or stored.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mutedText, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _uploaderCard(AcademicResource resource, String uploader) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: AppColors.lightBlue,
          child: Icon(Icons.person_outline, color: AppColors.deepPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                uploader,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_roleLabel(_roleForUploader(resource.uploaderId))} · ${resource.department}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _documentPreview(AcademicResource resource) => Container(
    height: 188,
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.lightBlue),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          resource.fileType == 'application/pdf'
              ? Icons.picture_as_pdf_outlined
              : resource.fileType == 'application/zip'
              ? Icons.folder_zip_outlined
              : Icons.slideshow_outlined,
          size: 46,
          color: AppColors.deepPrimary,
        ),
        const SizedBox(height: 9),
        Text(
          resource.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Document preview is not available in this local demo.',
          style: TextStyle(color: AppColors.mutedText, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _metadataCard(AcademicResource resource) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Academic Classification',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 11),
        _metadataLine('Subject', resource.subject),
        _metadataLine(
          'Semester',
          resource.semester == null
              ? 'Not specified'
              : 'Semester ${resource.semester}',
        ),
        _metadataLine('Category', resource.category.label),
        _metadataLine('Department', resource.department),
        if (resource.academicYear.isNotEmpty)
          _metadataLine('Academic Year', resource.academicYear),
        _metadataLine('Uploaded', resourceDate(resource.uploadedAt)),
        _metadataLine('File Size', resource.fileSizeLabel),
      ],
    ),
  );

  Widget _metadataLine(String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            key,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _downloadUnavailable(ResourceStatus status) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.lock_outline, color: AppColors.error, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            '${status.label} resources cannot be downloaded.',
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  void _download(
    BuildContext context,
    ResourceStore store,
    AcademicResource resource,
  ) {
    final result = store.requestDownload(resource.id);
    final message = result == ResourceDownloadResult.previewAllowed
        ? 'Download preview only; no file was downloaded or saved.'
        : 'This resource is not available for download.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  UserProfileRole _roleForUploader(String uploaderId) =>
      ResourceStore.instance.mockUploaderRole(uploaderId);

  String _roleLabel(UserProfileRole role) => switch (role) {
    UserProfileRole.student => 'Student',
    UserProfileRole.senior => 'Senior',
    UserProfileRole.alumni => 'Alumni',
    UserProfileRole.admin => 'Admin',
  };
}

extension on ResourceStatus {
  String get label => switch (this) {
    ResourceStatus.published => 'Published',
    ResourceStatus.underReview => 'Under Review',
    ResourceStatus.restricted => 'Restricted',
    ResourceStatus.removed => 'Removed',
  };
}
