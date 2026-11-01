import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource.dart';
import '../models/resource_report.dart';
import '../services/resource_store.dart';
import '../widgets/resource_widgets.dart';

class ResourceReportScreen extends StatefulWidget {
  const ResourceReportScreen({
    required this.viewerRole,
    required this.resourceId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String resourceId;

  @override
  State<ResourceReportScreen> createState() => _ResourceReportScreenState();
}

class _ResourceReportScreenState extends State<ResourceReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  ResourceReportReason _reason = ResourceReportReason.copyrightConcern;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ResourceStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final resource = store.resourceById(widget.resourceId);
        if (resource == null ||
            resource.status != ResourceStatus.published ||
            widget.viewerRole == UserProfileRole.admin) {
          return ResourcePage(
            title: 'Report Resource',
            child: const ResourceEmptyState(
              title: 'Reporting unavailable',
              message: 'Only published resources can be reported by student, senior, or alumni accounts.',
            ),
          );
        }
        return ResourcePage(
          title: 'Report Resource',
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 24),
              children: [
                _resourceSummary(resource, store),
                const SizedBox(height: 17),
                const Text(
                  'Why are you reporting this resource?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose the primary concern that best describes the issue.',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 11),
                ),
                const SizedBox(height: 10),
                RadioGroup<ResourceReportReason>(
                  groupValue: _reason,
                  onChanged: (value) {
                    if (value != null) setState(() => _reason = value);
                  },
                  child: Column(
                    children: [
                      for (final reason in ResourceReportReason.values)
                        _reasonCard(reason),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Additional Details (Optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _detailsController,
                  maxLength: 500,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Provide additional information about this report...',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.deepPrimary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reports remain in this local preview. Submitting a report does not automatically change the resource status.',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  height: 49,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    onPressed: () => _submit(store),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Submit Report'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resourceSummary(
    AcademicResource resource,
    ResourceStore store,
  ) => Container(
    padding: const EdgeInsets.all(13),
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
                '${store.uploaderName(resource.uploaderId, viewerRole: widget.viewerRole)} · ${resource.category.label} · ${resource.fileSizeLabel}',
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

  Widget _reasonCard(ResourceReportReason reason) {
    final selected = _reason == reason;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? AppColors.lightBlue : AppColors.white,
      child: RadioListTile<ResourceReportReason>(
        value: reason,
        title: Text(
          reason.label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _submit(ResourceStore store) {
    if (!_formKey.currentState!.validate()) return;
    final result = store.reportResource(
      resourceId: widget.resourceId,
      reporterId: store.currentUserId(widget.viewerRole),
      reporterRole: widget.viewerRole,
      reason: _reason,
      details: _detailsController.text,
    );
    final message = switch (result) {
      ResourceReportResult.submitted =>
        'Report submitted for moderation. Resource status is unchanged.',
      ResourceReportResult.duplicate =>
        'You have already reported this resource.',
      ResourceReportResult.unavailable => 'This resource cannot be reported.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    if (result == ResourceReportResult.submitted) {
      Navigator.of(context).pop();
    }
  }
}
