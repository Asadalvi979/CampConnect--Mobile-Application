import '../../profile/models/user_profile.dart';

class MentorshipRouteArguments {
  const MentorshipRouteArguments({
    this.viewerRole = UserProfileRole.student,
    this.alumniId,
    this.requestId,
    this.initialTab,
  });

  final UserProfileRole viewerRole;
  final String? alumniId;
  final String? requestId;
  final int? initialTab;
}
