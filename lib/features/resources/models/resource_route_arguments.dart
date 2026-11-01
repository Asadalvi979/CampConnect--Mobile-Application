import '../../profile/models/user_profile.dart';

class ResourceRouteArguments {
  const ResourceRouteArguments({
    required this.viewerRole,
    this.resourceId,
    this.reportId,
  });

  final UserProfileRole viewerRole;
  final String? resourceId;
  final String? reportId;
}
