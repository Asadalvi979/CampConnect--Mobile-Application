import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home_dashboard/models/dashboard_role.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../../project_collaboration/models/project_route_arguments.dart';
import '../models/resource.dart';
import '../models/resource_report.dart';

class ResourcePage extends StatelessWidget {
  const ResourcePage({
    required this.title,
    required this.child,
    this.actions,
    this.bottomNavigationBar,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: child,
        ),
      ),
    ),
    bottomNavigationBar: bottomNavigationBar,
  );
}

class ResourceBottomBar extends StatelessWidget {
  const ResourceBottomBar({
    required this.viewerRole,
    this.active = 'Resources',
    super.key,
  });

  final UserProfileRole viewerRole;
  final String active;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.lightBlue)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, 'Home', Icons.home_outlined),
          _item(context, 'Community', Icons.groups_outlined),
          _item(context, 'Projects', Icons.folder_open_outlined),
          _item(context, 'Messages', Icons.chat_bubble_outline),
          _item(context, 'Profile', Icons.person_outline),
        ],
      ),
    ),
  );

  Widget _item(BuildContext context, String label, IconData icon) {
    final selected = active == label;
    return InkWell(
      onTap: () {
        switch (label) {
          case 'Home':
            final role = switch (viewerRole) {
              UserProfileRole.student ||
              UserProfileRole.admin => DashboardRole.student,
              UserProfileRole.senior => DashboardRole.senior,
              UserProfileRole.alumni => DashboardRole.alumni,
            };
            Navigator.of(context).pushNamed(AppRoutes.dashboardRouteFor(role));
          case 'Community':
            Navigator.of(context).pushNamed(AppRoutes.communities);
          case 'Projects':
            Navigator.of(context).pushNamed(
              AppRoutes.projects,
              arguments: ProjectRouteArguments(viewerRole: viewerRole),
            );
          case 'Messages':
            openMessageInbox(context, viewerRole: viewerRole);
          case 'Profile':
            final role = switch (viewerRole) {
              UserProfileRole.student ||
              UserProfileRole.admin => DashboardRole.student,
              UserProfileRole.senior => DashboardRole.senior,
              UserProfileRole.alumni => DashboardRole.alumni,
            };
            Navigator.of(context).pushNamed(AppRoutes.profile, arguments: role);
        }
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.deepPrimary : AppColors.secondaryText,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: selected
                    ? AppColors.deepPrimary
                    : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResourceStatusChip extends StatelessWidget {
  const ResourceStatusChip(this.status, {super.key});

  final ResourceStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      ResourceStatus.published => (
        'Published',
        AppColors.success,
        Icons.check_circle_outline,
      ),
      ResourceStatus.underReview => (
        'Under Review',
        AppColors.deepPrimary,
        Icons.hourglass_top_rounded,
      ),
      ResourceStatus.restricted => (
        'Restricted',
        AppColors.error,
        Icons.lock_outline,
      ),
      ResourceStatus.removed => (
        'Removed',
        AppColors.mutedText,
        Icons.remove_circle_outline,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ResourceCard extends StatelessWidget {
  const ResourceCard({
    required this.resource,
    required this.uploaderName,
    required this.onTap,
    this.showStatus = false,
    super.key,
  });

  final AcademicResource resource;
  final String uploaderName;
  final VoidCallback onTap;
  final bool showStatus;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: AppColors.border.withValues(alpha: 0.55)),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: resource.fileType == 'application/pdf'
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.paleBlue,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                resource.fileType == 'application/pdf'
                    ? Icons.picture_as_pdf_outlined
                    : resource.fileType == 'application/zip'
                    ? Icons.folder_zip_outlined
                    : Icons.slideshow_outlined,
                color: resource.fileType == 'application/pdf'
                    ? AppColors.error
                    : AppColors.deepPrimary,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showStatus)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ResourceStatusChip(resource.status),
                    ),
                  Text(
                    resource.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${resource.category.label} · ${resource.subject}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.deepPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$uploaderName · ${resource.fileType.split('/').last.toUpperCase()} · ${resource.fileSizeLabel}',
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
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
          ],
        ),
      ),
    ),
  );
}

class ResourceEmptyState extends StatelessWidget {
  const ResourceEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.menu_book_outlined,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AppColors.paleBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepPrimary, size: 34),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}

class ResourceReportBadge extends StatelessWidget {
  const ResourceReportBadge({required this.reason, super.key});

  final ResourceReportReason reason;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      reason.label,
      style: const TextStyle(
        color: AppColors.deepPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
    ),
  );
}

String resourceDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
