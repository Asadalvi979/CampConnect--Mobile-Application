import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../admin_panel/widgets/admin_panel_layout.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource.dart';
import '../models/resource_report.dart';
import '../services/resource_store.dart';
import '../widgets/resource_widgets.dart';

class ResourceModerationDetailsScreen extends StatefulWidget {
  const ResourceModerationDetailsScreen({
    required this.viewerRole,
    required this.reportId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String reportId;

  @override
  State<ResourceModerationDetailsScreen> createState() =>
      _ResourceModerationDetailsScreenState();
}

class _ResourceModerationDetailsScreenState
    extends State<ResourceModerationDetailsScreen> {
  ResourceModerationDecision? _decision;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final store = ResourceStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final report = store.reportById(widget.reportId);
        final resource = report == null
            ? null
            : store.resourceById(report.resourceId);
        if (widget.viewerRole != UserProfileRole.admin) {
          return ResourcePage(
            title: 'Moderation Review',
            bottomNavigationBar: widget.viewerRole == UserProfileRole.admin
                ? const AdminPanelBottomNavigation(
                    selected: AdminPanelSection.resources,
                  )
                : null,
            child: const ResourceEmptyState(
              title: 'Administrator access required',
              message: 'Only administrators can review reported resources.',
              icon: Icons.admin_panel_settings_outlined,
            ),
          );
        }
        if (report == null || resource == null || report.isReviewed) {
          return ResourcePage(
            title: 'Moderation Review',
            bottomNavigationBar: const AdminPanelBottomNavigation(
              selected: AdminPanelSection.resources,
            ),
            child: const ResourceEmptyState(
              title: 'Report unavailable',
              message:
                  'This report has already been reviewed or was not found.',
              icon: Icons.inbox_outlined,
            ),
          );
        }
        return ResourcePage(
          title: 'Moderation Review',
          bottomNavigationBar: const AdminPanelBottomNavigation(
            selected: AdminPanelSection.resources,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 22),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Resource report',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  ResourceStatusChip(resource.status),
                ],
              ),
              const SizedBox(height: 11),
              _resourceCard(resource),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ResourceReportBadge(reason: report.reason),
                    const SizedBox(height: 8),
                    Text(
                      'Submitted ${resourceDate(report.createdAt)}',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                    if (report.details?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        report.details!,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Moderation decision',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the outcome for this resource. Review does not delete the mock file.',
                style: TextStyle(color: AppColors.mutedText, fontSize: 11),
              ),
              const SizedBox(height: 9),
              RadioGroup<ResourceModerationDecision>(
                groupValue: _decision,
                onChanged: (value) => setState(() => _decision = value),
                child: Column(
                  children: [
                    _decisionCard(
                      ResourceModerationDecision.keepPublished,
                      'Approve / Keep Published',
                      'Set the resource status to Published.',
                      Icons.check_circle_outline,
                    ),
                    _decisionCard(
                      ResourceModerationDecision.restrict,
                      'Restrict Resource',
                      'Set the resource status to Restricted.',
                      Icons.lock_outline,
                    ),
                    _decisionCard(
                      ResourceModerationDecision.remove,
                      'Remove Resource',
                      'Set the resource status to Removed.',
                      Icons.remove_circle_outline,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 49,
                child: FilledButton.icon(
                  onPressed: _decision == null || _isSubmitting
                      ? null
                      : () => _commit(store, report),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.assignment_turned_in_outlined),
                  label: Text(
                    _isSubmitting ? 'Applying decision...' : 'Apply Decision',
                  ),
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'This local preview does not email users, store audit logs, or delete files.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mutedText, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _resourceCard(AcademicResource resource) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resource.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          '${resource.category.label} · ${resource.subject} · ${resource.fileName}',
          style: const TextStyle(color: AppColors.mutedText, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          '${resource.fileType.split('/').last.toUpperCase()} · ${resource.fileSizeLabel} · Uploaded ${resourceDate(resource.uploadedAt)}',
          style: const TextStyle(color: AppColors.mutedText, fontSize: 10),
        ),
        if (resource.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            resource.description!,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _decisionCard(
    ResourceModerationDecision decision,
    String title,
    String description,
    IconData icon,
  ) {
    final selected = _decision == decision;
    return Card(
      color: selected ? AppColors.paleBlue : AppColors.white,
      child: RadioListTile<ResourceModerationDecision>(
        value: decision,
        title: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.deepPrimary),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 10, color: AppColors.mutedText),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Future<void> _commit(ResourceStore store, ResourceReport report) async {
    if (_decision == null) return;
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    final result = store.moderateReport(
      reportId: report.id,
      moderatorRole: widget.viewerRole,
      moderatorId: store.currentUserId(widget.viewerRole),
      decision: _decision!,
    );
    setState(() => _isSubmitting = false);
    final message = switch (result) {
      ResourceModerationResult.updated => switch (_decision!) {
        ResourceModerationDecision.keepPublished =>
          'Resource status set to Published.',
        ResourceModerationDecision.restrict =>
          'Resource status set to Restricted.',
        ResourceModerationDecision.remove => 'Resource status set to Removed.',
      },
      ResourceModerationResult.unauthorized =>
        'Administrator access is required.',
      ResourceModerationResult.unavailable =>
        'This report is no longer available for review.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    if (result == ResourceModerationResult.updated) {
      Navigator.of(context).pop();
    }
  }
}
