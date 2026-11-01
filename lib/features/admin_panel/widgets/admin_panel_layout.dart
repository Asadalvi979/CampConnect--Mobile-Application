import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../../resources/models/resource_route_arguments.dart';

enum AdminPanelSection { dashboard, users, resources, announcements }

class AdminPanelLayout extends StatelessWidget {
  const AdminPanelLayout({
    required this.title,
    required this.section,
    required this.child,
    this.showBackButton = false,
    super.key,
  });

  final String title;
  final AdminPanelSection section;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    if (UserProfileStore.instance.profile.value.role != UserProfileRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 48,
                  color: AppColors.deepPrimary,
                ),
                SizedBox(height: 12),
                Text(
                  'Administrator access required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'This local preview is available only for the Admin role.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        if (isWide) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  _AdminSidebar(selected: section),
                  Expanded(
                    child: Column(
                      children: [
                        _AdminHeader(
                          title: title,
                          showBackButton: showBackButton,
                          onLogout: () => _logout(context),
                        ),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: showBackButton
                ? BackButton(onPressed: () => Navigator.maybePop(context))
                : null,
            title: Text(title),
            actions: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notifications),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                tooltip: 'Log out of Admin preview',
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: SafeArea(top: false, child: child),
          bottomNavigationBar: AdminPanelBottomNavigation(selected: section),
        );
      },
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.title,
    required this.showBackButton,
    required this.onLogout,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 28),
    decoration: const BoxDecoration(
      color: AppColors.white,
      border: Border(bottom: BorderSide(color: AppColors.border, width: .5)),
    ),
    child: Row(
      children: [
        if (showBackButton)
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
        ),
        const Chip(
          avatar: Icon(
            Icons.admin_panel_settings_outlined,
            size: 17,
            color: AppColors.deepPrimary,
          ),
          label: Text('Admin preview'),
          backgroundColor: AppColors.paleBlue,
          side: BorderSide.none,
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          tooltip: 'Log out of Admin preview',
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    ),
  );
}

void _logout(BuildContext context) {
  UserProfileStore.instance.setRole(UserProfileRole.student);
  Navigator.of(context)
      .pushNamedAndRemoveUntil(AppRoutes.adminLogin, (route) => false);
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({required this.selected});

  final AdminPanelSection selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 248,
    color: AppColors.white,
    padding: const EdgeInsets.fromLTRB(17, 22, 14, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: AppColors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CampConnect',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'ADMIN CONSOLE',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.mutedText,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 34),
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 9),
          child: Text(
            'WORKSPACE',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        _NavItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selected: selected == AdminPanelSection.dashboard,
          onTap: () => _go(context, AppRoutes.adminDashboard),
        ),
        _NavItem(
          label: 'User Management',
          icon: Icons.people_outline,
          selected: selected == AdminPanelSection.users,
          onTap: () => _go(context, AppRoutes.adminUsers),
        ),
        _NavItem(
          label: 'Resource Moderation',
          icon: Icons.fact_check_outlined,
          selected: selected == AdminPanelSection.resources,
          onTap: () => navigateToAdminSection(
            context,
            AppRoutes.resourceModeration,
            arguments: const ResourceRouteArguments(
              viewerRole: UserProfileRole.admin,
            ),
          ),
        ),
        _NavItem(
          label: 'Announcements',
          icon: Icons.campaign_outlined,
          selected: selected == AdminPanelSection.announcements,
          onTap: () => _go(context, AppRoutes.announcements),
        ),
        const Spacer(),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Text(
            'Local mock data · resets on restart',
            style: TextStyle(color: AppColors.mutedText, fontSize: 10),
          ),
        ),
      ],
    ),
  );

  void _go(BuildContext context, String route) =>
      navigateToAdminSection(context, route);
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Material(
      color: Colors.transparent,
      child: ListTile(
        selected: selected,
        selectedColor: AppColors.deepPrimary,
        selectedTileColor: AppColors.paleBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        onTap: onTap,
      ),
    ),
  );
}

class AdminPanelBottomNavigation extends StatelessWidget {
  const AdminPanelBottomNavigation({required this.selected, super.key});

  final AdminPanelSection selected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = switch (selected) {
      AdminPanelSection.dashboard => 0,
      AdminPanelSection.users => 1,
      AdminPanelSection.resources => 2,
      AdminPanelSection.announcements => 3,
    };
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Home',
        ),
        NavigationDestination(icon: Icon(Icons.people_outline), label: 'Users'),
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          label: 'Resources',
        ),
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          label: 'News',
        ),
      ],
      onDestinationSelected: (index) {
        final route = switch (index) {
          0 => AppRoutes.adminDashboard,
          1 => AppRoutes.adminUsers,
          2 => AppRoutes.resourceModeration,
          _ => AppRoutes.announcements,
        };
        if (index == 2) {
          navigateToAdminSection(
            context,
            route,
            arguments: const ResourceRouteArguments(
              viewerRole: UserProfileRole.admin,
            ),
          );
        } else {
          navigateToAdminSection(context, route);
        }
      },
    );
  }
}

void navigateToAdminSection(
  BuildContext context,
  String route, {
  Object? arguments,
}) {
  final navigator = Navigator.of(context);
  var destinationExists = false;
  navigator.popUntil((candidate) {
    if (candidate.settings.name == route) {
      destinationExists = true;
      return true;
    }
    return candidate.isFirst;
  });
  if (!destinationExists) {
    navigator.pushNamed(route, arguments: arguments);
  }
}
