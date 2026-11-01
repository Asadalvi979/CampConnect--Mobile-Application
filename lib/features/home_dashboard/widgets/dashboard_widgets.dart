import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../notifications_announcements/services/notification_announcement_store.dart';
import '../../notifications_announcements/widgets/notifications_navigation.dart';
import '../../project_collaboration/models/project_route_arguments.dart';
import '../models/dashboard_role.dart';

void showDashboardPreviewMessage(BuildContext context, String module) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '$module is not available yet. This dashboard uses local preview data.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void openCommunityList(BuildContext context) {
  Navigator.of(context).pushNamed(AppRoutes.communities);
}

void openProjectDiscovery(BuildContext context, DashboardRole role) {
  final viewerRole = switch (role) {
    DashboardRole.student => UserProfileRole.student,
    DashboardRole.senior => UserProfileRole.senior,
    DashboardRole.alumni => UserProfileRole.alumni,
  };
  Navigator.of(context).pushNamed(
    AppRoutes.projects,
    arguments: ProjectRouteArguments(viewerRole: viewerRole),
  );
}

class DashboardFrame extends StatelessWidget {
  const DashboardFrame({required this.role, required this.child, super.key});

  final DashboardRole role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                DashboardTopBar(role: role),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomBar(role: role),
    );
  }
}

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({required this.role, super.key});

  final DashboardRole role;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: AppColors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CampConnect',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    '${role.label} Home Dashboard',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: NotificationAnnouncementStore.instance,
              builder: (context, _) {
                final userRole = switch (role) {
                  DashboardRole.student => UserProfileRole.student,
                  DashboardRole.senior => UserProfileRole.senior,
                  DashboardRole.alumni => UserProfileRole.alumni,
                };
                final store = NotificationAnnouncementStore.instance;
                final unreadCount = store.unreadCountFor(
                  store.userIdFor(userRole),
                );
                return IconButton(
                  tooltip:
                      'Notifications${unreadCount == 0 ? '' : ': $unreadCount unread'}',
                  onPressed: () => openNotifications(context),
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                );
              },
            ),
            InkWell(
              onTap: () =>
                  Navigator.of(context)
                      .pushNamed(AppRoutes.profile, arguments: role),
              borderRadius: BorderRadius.circular(24),
              child: const CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.lightBlue,
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.deepPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBottomBar extends StatelessWidget {
  const DashboardBottomBar({this.role = DashboardRole.student, super.key});

  final DashboardRole role;

  final _items = const [
    (label: 'Home', icon: Icons.home_outlined, route: null),
    (
      label: 'Community',
      icon: Icons.groups_outlined,
      route: AppRoutes.communities,
    ),
    (
      label: 'Projects',
      icon: Icons.folder_open_outlined,
      route: AppRoutes.projects,
    ),
    (
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      route: AppRoutes.messages,
    ),
    (label: 'Profile', icon: Icons.person_outline, route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
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
            for (final item in _items)
              InkWell(
                onTap: item.route == null
                    ? null
                    : () {
                        if (item.label == 'Profile') {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.profile, arguments: role);
                        } else if (item.label == 'Community') {
                          openCommunityList(context);
                        } else if (item.label == 'Projects') {
                          openProjectDiscovery(context, role);
                        } else if (item.label == 'Messages') {
                          openMessageInbox(
                            context,
                            viewerRole: switch (role) {
                              DashboardRole.student => UserProfileRole.student,
                              DashboardRole.senior => UserProfileRole.senior,
                              DashboardRole.alumni => UserProfileRole.alumni,
                            },
                          );
                        } else {
                          showDashboardPreviewMessage(context, item.label);
                        }
                      },
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: item.route == null
                            ? AppColors.deepPrimary
                            : AppColors.secondaryText,
                        size: 21,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: item.route == null
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

class DashboardSectionTitle extends StatelessWidget {
  const DashboardSectionTitle(
    this.title, {
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9, top: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          if (trailing != null)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                foregroundColor: AppColors.deepPrimary,
              ),
              child: Text(trailing!, style: const TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color = AppColors.white,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DashboardShortcut extends StatelessWidget {
  const DashboardShortcut({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accent = AppColors.lightBlue,
    this.compact = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(compact ? 9 : 12),
          child: compact
              ? Column(
                  children: [
                    _icon(),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _icon(),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _icon() => Container(
    width: compact ? 38 : 38,
    height: compact ? 38 : 38,
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, size: 20, color: AppColors.deepPrimary),
  );
}

class DashboardAvatar extends StatelessWidget {
  const DashboardAvatar(this.initials, {this.radius = 22, super.key});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: AppColors.lightBlue,
    child: Text(
      initials,
      style: const TextStyle(
        color: AppColors.deepPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  );
}

class DashboardPill extends StatelessWidget {
  const DashboardPill(this.text, {this.color = AppColors.lightBlue, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 9, color: AppColors.deepPrimary),
    ),
  );
}
