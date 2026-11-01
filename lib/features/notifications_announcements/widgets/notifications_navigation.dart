import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../models/announcement_route_arguments.dart';

void openNotifications(BuildContext context) {
  Navigator.of(context).pushNamed(AppRoutes.notifications);
}

void openAnnouncements(BuildContext context) {
  Navigator.of(context).pushNamed(AppRoutes.announcements);
}

void openAnnouncementDetails(
  BuildContext context, {
  required int announcementId,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.announcementDetails,
    arguments: AnnouncementRouteArguments(announcementId: announcementId),
  );
}
