import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource.dart';
import '../services/resource_store.dart';
import '../widgets/resource_widgets.dart';

class ResourceStatusScreen extends StatelessWidget {
  const ResourceStatusScreen({
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
        final viewerId = store.currentUserId(viewerRole);
        if (resource == null ||
            (resource.uploaderId != viewerId &&
                viewerRole != UserProfileRole.admin)) {
          return ResourcePage(
            title: 'Resource Status',
            child: const ResourceEmptyState(
              title: 'Status unavailable',
              message: 'Only the resource uploader or an administrator can view this status.',
            ),
          );
        }
        return ResourcePage(
          title: 'Resource Status',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(17, 15, 17, 24),
            children: [
              _resourceHeader(resource),
              const SizedBox(height: 15),
              Center(child: ResourceStatusChip(resource.status)),
              const SizedBox(height: 13),
              Text(
                _statusHeading(resource.status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _statusDescription(resource.status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Resource status definitions',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 9),
              for (final status in ResourceStatus.values)
                _statusDefinition(status, selected: status == resource.status),
              const SizedBox(height: 13),
              if (resource.status != ResourceStatus.published)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Download unavailable (${resource.status.label}).',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (resource.status == ResourceStatus.underReview) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _showAppealUnavailable(context),
                  icon: const Icon(Icons.contact_support_outlined),
                  label: const Text('Contact Academic Support / Appeal'),
                ),
                const Text(
                  'Appeal submission is not defined by the current SRS/ERD and is unavailable in this preview.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to My Resources'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Local mock state only. No scanning, storage, notifications, or appeals are performed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mutedText, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _resourceHeader(AcademicResource resource) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.insert_drive_file_outlined,
          color: AppColors.deepPrimary,
          size: 31,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${resource.category.label} · ${resource.subject} · ${resource.fileSizeLabel}',
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

  Widget _statusDefinition(ResourceStatus status, {required bool selected}) {
    final description = switch (status) {
      ResourceStatus.published =>
        'Visible in the resource library and downloadable.',
      ResourceStatus.underReview =>
        'Awaiting moderation review; downloads are unavailable.',
      ResourceStatus.restricted =>
        'Access is restricted; downloads are unavailable.',
      ResourceStatus.removed =>
        'Removed from normal access; downloads are unavailable.',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? AppColors.paleBlue : AppColors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResourceStatusChip(status),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusHeading(ResourceStatus status) => switch (status) {
    ResourceStatus.published => 'Your resource is published',
    ResourceStatus.underReview => 'Your resource is under review',
    ResourceStatus.restricted => 'Your resource is restricted',
    ResourceStatus.removed => 'Your resource was removed',
  };

  String _statusDescription(ResourceStatus status) => switch (status) {
    ResourceStatus.published =>
      'This resource is visible in the library and available for download.',
    ResourceStatus.underReview => 'This resource is awaiting moderation review. It cannot be downloaded while under review.',
    ResourceStatus.restricted =>
      'This resource is unavailable to other users while restricted.',
    ResourceStatus.removed =>
      'This resource has been removed from normal access.',
  };

  void _showAppealUnavailable(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appeals unavailable'),
        content: const Text(
          'An appeal workflow is not defined in the current Resources requirements. No inquiry was sent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

extension on ResourceStatus {
  String get label => switch (this) {
    ResourceStatus.published => 'Published',
    ResourceStatus.underReview => 'Under Review',
    ResourceStatus.restricted => 'Restricted',
    ResourceStatus.removed => 'Removed',
  };
}
