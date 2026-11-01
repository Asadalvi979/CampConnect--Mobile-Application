import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../admin_panel/widgets/admin_panel_layout.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource.dart';
import '../models/resource_report.dart';
import '../services/resource_store.dart';
import '../widgets/resource_navigation.dart';
import '../widgets/resource_widgets.dart';

class ResourceModerationScreen extends StatefulWidget {
  const ResourceModerationScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<ResourceModerationScreen> createState() =>
      _ResourceModerationScreenState();
}

class _ResourceModerationScreenState extends State<ResourceModerationScreen> {
  final _searchController = TextEditingController();
  ResourceStatus? _status;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewerRole != UserProfileRole.admin) {
      return ResourcePage(
        title: 'Resource Moderation',
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
    final store = ResourceStore.instance;
    return ResourcePage(
      title: 'Resource Moderation',
      bottomNavigationBar: widget.viewerRole == UserProfileRole.admin
          ? const AdminPanelBottomNavigation(
              selected: AdminPanelSection.resources,
            )
          : null,
      actions: [
        IconButton(
          tooltip: 'Resource Library',
          onPressed: () =>
              openResourceLibrary(context, viewerRole: widget.viewerRole),
          icon: const Icon(Icons.menu_book_outlined),
        ),
      ],
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final reports = store.openReports().where((report) {
            final resource = store.resourceById(report.resourceId);
            if (resource == null ||
                (_status != null && resource.status != _status)) {
              return false;
            }
            final query = _searchController.text.trim().toLowerCase();
            return query.isEmpty ||
                resource.title.toLowerCase().contains(query) ||
                resource.subject.toLowerCase().contains(query) ||
                report.reason.label.toLowerCase().contains(query);
          }).toList();
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 13, 15, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gavel_outlined,
                      color: AppColors.deepPrimary,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${store.openReports().length} open reports',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Text(
                      'Resource reports only',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 7),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search title, subject, or report reason',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 45,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _statusChip('All', null),
                    for (final status in ResourceStatus.values)
                      _statusChip(status.label, status),
                  ],
                ),
              ),
              Expanded(
                child: reports.isEmpty
                    ? const ResourceEmptyState(
                        title: 'No matching reports',
                        message: 'Reported resources awaiting review will appear here.',
                        icon: Icons.inbox_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 18),
                        itemCount: reports.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 9),
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          final resource = store.resourceById(
                            report.resourceId,
                          );
                          if (resource == null) return const SizedBox.shrink();
                          return _reportCard(context, report, resource, store);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, ResourceStatus? status) {
    final selected = _status == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _status = status),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.paleBlue,
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.deepPrimary,
          fontSize: 10,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _reportCard(
    BuildContext context,
    ResourceReport report,
    AcademicResource resource,
    ResourceStore store,
  ) {
    final uploader = store.uploaderName(
      resource.uploaderId,
      viewerRole: UserProfileRole.admin,
    );
    return Card(
      color: AppColors.white,
      child: InkWell(
        onTap: () => openResourceModerationDetails(
          context,
          reportId: report.id,
          viewerRole: widget.viewerRole,
        ),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: ResourceStatusChip(resource.status)),
                  Text(
                    resourceDate(report.createdAt),
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                resource.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$uploader · ${resource.subject}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              ResourceReportBadge(reason: report.reason),
              if (report.details?.isNotEmpty == true) ...[
                const SizedBox(height: 7),
                Text(
                  report.details!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Review report  ›',
                  style: TextStyle(
                    color: AppColors.deepPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
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
