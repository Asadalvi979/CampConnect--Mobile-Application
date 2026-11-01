import '../../profile/models/user_profile.dart';

class ProjectRouteArguments {
  const ProjectRouteArguments({
    this.viewerRole = UserProfileRole.student,
    this.projectId,
    this.applicantId,
  });

  final UserProfileRole viewerRole;
  final String? projectId;
  final String? applicantId;
}
