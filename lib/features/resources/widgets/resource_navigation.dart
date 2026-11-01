import 'package:flutter/material.dart';

import '../../home_dashboard/models/dashboard_role.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource_route_arguments.dart';

void openResourceLibrary(BuildContext context, {UserProfileRole? viewerRole}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.resources,
    arguments: ResourceRouteArguments(viewerRole: role),
  );
}

void openMyResources(BuildContext context, {UserProfileRole? viewerRole}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.myResources,
    arguments: ResourceRouteArguments(viewerRole: role),
  );
}

void openResourceUpload(BuildContext context, {UserProfileRole? viewerRole}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.resourceUpload,
    arguments: ResourceRouteArguments(viewerRole: role),
  );
}

void openResourceDetails(
  BuildContext context, {
  required String resourceId,
  UserProfileRole? viewerRole,
}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.resourceDetails,
    arguments: ResourceRouteArguments(viewerRole: role, resourceId: resourceId),
  );
}

void openResourceStatus(
  BuildContext context, {
  required String resourceId,
  UserProfileRole? viewerRole,
}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.resourceStatus,
    arguments: ResourceRouteArguments(viewerRole: role, resourceId: resourceId),
  );
}

void openResourceModeration(
  BuildContext context, {
  UserProfileRole? viewerRole,
}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.resourceModeration,
    arguments: ResourceRouteArguments(viewerRole: role),
  );
}

void openResourceModerationDetails(
  BuildContext context, {
  required String reportId,
  UserProfileRole? viewerRole,
}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.resourceModerationDetails,
    arguments: ResourceRouteArguments(viewerRole: role, reportId: reportId),
  );
}

void openResourceReport(
  BuildContext context, {
  required String resourceId,
  UserProfileRole? viewerRole,
}) {
  final role = viewerRole ?? UserProfileStore.instance.profile.value.role;
  Navigator.of(context).pushNamed(
    AppRoutes.resourceReport,
    arguments: ResourceRouteArguments(viewerRole: role, resourceId: resourceId),
  );
}

void openResourceDashboard(BuildContext context, UserProfileRole role) {
  Navigator.of(context).pushNamed(
    AppRoutes.dashboardRouteFor(switch (role) {
      UserProfileRole.student || UserProfileRole.admin => DashboardRole.student,
      UserProfileRole.senior => DashboardRole.senior,
      UserProfileRole.alumni => DashboardRole.alumni,
    }),
  );
}

void openResourceBottomBarMessages(BuildContext context, UserProfileRole role) {
  openMessageInbox(context, viewerRole: role);
}
