import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home_dashboard/models/dashboard_role.dart';
import '../../navigation/app_routes.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../profile/models/user_profile.dart';
import '../models/project_route_arguments.dart';

void showProjectMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.deepPrimary,
      ),
    );
}

class ProjectScaffold extends StatelessWidget {
  const ProjectScaffold({
    required this.title,
    required this.body,
    this.viewerRole = UserProfileRole.student,
    this.actions = const [],
    this.showBottomBar = false,
    this.showBackButton = true,
    this.bottom,
    super.key,
  });

  final String title;
  final Widget body;
  final UserProfileRole viewerRole;
  final List<Widget> actions;
  final bool showBottomBar;
  final bool showBackButton;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Text(title, style: const TextStyle(fontSize: 17)),
      actions: actions,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: body,
        ),
      ),
    ),
    bottomNavigationBar:
        bottom ??
        (showBottomBar ? ProjectBottomBar(viewerRole: viewerRole) : null),
  );
}

class ProjectCardSurface extends StatelessWidget {
  const ProjectCardSurface({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.white,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryText.withValues(alpha: 0.035),
          blurRadius: 9,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}

class ProjectPill extends StatelessWidget {
  const ProjectPill(
    this.label, {
    this.color = AppColors.lightBlue,
    this.textColor = AppColors.deepPrimary,
    super.key,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class ProjectStatusPill extends StatelessWidget {
  const ProjectStatusPill({
    required this.label,
    required this.color,
    required this.textColor,
    super.key,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) =>
      ProjectPill(label, color: color, textColor: textColor);
}

class ProjectAvatar extends StatelessWidget {
  const ProjectAvatar(this.name, {this.radius = 22, super.key});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightBlue,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.deepPrimary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.56,
        ),
      ),
    );
  }
}

class ProjectEmptyState extends StatelessWidget {
  const ProjectEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.rocket_launch_outlined,
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
          Icon(icon, size: 44, color: AppColors.deepPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

class ProjectBottomBar extends StatelessWidget {
  const ProjectBottomBar({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  Widget build(BuildContext context) {
    final dashboardRole = switch (viewerRole) {
      UserProfileRole.senior => DashboardRole.senior,
      UserProfileRole.alumni => DashboardRole.alumni,
      _ => DashboardRole.student,
    };
    final items = [
      (label: 'Home', icon: Icons.home_outlined),
      (label: 'Community', icon: Icons.groups_outlined),
      (label: 'Projects', icon: Icons.rocket_launch_outlined),
      (label: 'Messages', icon: Icons.chat_bubble_outline),
      (label: 'Profile', icon: Icons.person_outline),
    ];
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.lightBlue)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final item in items)
              InkWell(
                onTap: () {
                  switch (item.label) {
                    case 'Home':
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.dashboardRouteFor(dashboardRole));
                    case 'Community':
                      Navigator.of(context).pushNamed(AppRoutes.communities);
                    case 'Projects':
                      break;
                    case 'Profile':
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.profile, arguments: dashboardRole);
                    case 'Messages':
                      openMessageInbox(context, viewerRole: viewerRole);
                  }
                },
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: item.label == 'Projects'
                            ? AppColors.deepPrimary
                            : AppColors.secondaryText,
                        size: 21,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: item.label == 'Projects'
                              ? AppColors.deepPrimary
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void openProjectList(BuildContext context, UserProfileRole role) =>
    Navigator.of(context).pushNamed(
      AppRoutes.projects,
      arguments: ProjectRouteArguments(viewerRole: role),
    );

void openMyProjects(BuildContext context, UserProfileRole role) =>
    Navigator.of(context).pushNamed(
      AppRoutes.myProjects,
      arguments: ProjectRouteArguments(viewerRole: role),
    );

void openProjectDetails(
  BuildContext context,
  UserProfileRole role,
  String projectId,
) => Navigator.of(context).pushNamed(
  AppRoutes.projectDetails,
  arguments: ProjectRouteArguments(viewerRole: role, projectId: projectId),
);

void openProjectCreate(BuildContext context, UserProfileRole role) =>
    Navigator.of(context).pushNamed(
      AppRoutes.projectCreate,
      arguments: ProjectRouteArguments(viewerRole: role),
    );

void openProjectEdit(
  BuildContext context,
  UserProfileRole role,
  String projectId,
) => Navigator.of(context).pushNamed(
  AppRoutes.projectEdit,
  arguments: ProjectRouteArguments(viewerRole: role, projectId: projectId),
);

void openProjectInterests(
  BuildContext context,
  UserProfileRole role,
  String projectId,
) => Navigator.of(context).pushNamed(
  AppRoutes.projectInterests,
  arguments: ProjectRouteArguments(viewerRole: role, projectId: projectId),
);

void openProjectInterestDetails(
  BuildContext context,
  UserProfileRole role,
  String projectId,
  String applicantId,
) => Navigator.of(context).pushNamed(
  AppRoutes.projectInterestDetails,
  arguments: ProjectRouteArguments(
    viewerRole: role,
    projectId: projectId,
    applicantId: applicantId,
  ),
);
