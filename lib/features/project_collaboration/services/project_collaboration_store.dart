import 'package:flutter/foundation.dart';

import '../../notifications_announcements/services/notification_announcement_store.dart';
import '../../profile/models/user_profile.dart';
import '../data/project_mock_data.dart';
import '../models/project_interest.dart';
import '../models/project_opportunity.dart';
import '../models/project_user_summary.dart';

enum SubmitProjectResult {
  created,
  unauthorized,
  notFound,
  closed,
  full,
  duplicate,
  invalidSkills,
}

enum ProjectDecisionResult {
  updated,
  notFound,
  unauthorized,
  alreadyProcessed,
  full,
}

class ProjectCollaborationStore extends ChangeNotifier {
  ProjectCollaborationStore._()
    : opportunities = List.of(ProjectMockData.opportunities),
      interests = List.of(ProjectMockData.interests);

  static final ProjectCollaborationStore instance =
      ProjectCollaborationStore._();

  final List<ProjectOpportunity> opportunities;
  final List<ProjectInterest> interests;
  var _nextProjectNumber = 1;

  String userIdFor(UserProfileRole role) => switch (role) {
    UserProfileRole.student => 'current-student',
    UserProfileRole.senior => 'current-senior',
    UserProfileRole.alumni => 'current-alumni',
    UserProfileRole.admin => 'current-admin',
  };

  ProjectOpportunity? project(String id) {
    for (final item in opportunities) {
      if (item.id == id) return item;
    }
    return null;
  }

  ProjectInterest? interest(String projectId, String applicantId) {
    for (final item in interests) {
      if (item.projectId == projectId && item.applicantId == applicantId) {
        return item;
      }
    }
    return null;
  }

  ProjectUserSummary userSummary(String userId, {UserProfileRole? viewerRole}) {
    final profile = UserProfileStore.instance.profile.value;
    if (userId == userIdFor(profile.role)) {
      return ProjectUserSummary(
        id: userId,
        name: profile.name,
        role: profile.role,
        program: profile.program,
        semester: profile.semester,
        university: profile.university,
        department: profile.department,
        location: profile.location,
        cgpa: profile.cgpa,
        skills: profile.skills,
      );
    }
    final seeded = ProjectMockData.users[userId];
    if (seeded != null) return seeded;

    final role = viewerRole ?? profile.role;
    return ProjectUserSummary(
      id: userId,
      name: switch (role) {
        UserProfileRole.student => 'CampConnect Student',
        UserProfileRole.senior => 'CampConnect Senior',
        UserProfileRole.alumni => 'CampConnect Alumni',
        UserProfileRole.admin => 'CampConnect Admin',
      },
      role: role,
      program: 'BS Software Engineering',
      semester: role == UserProfileRole.alumni ? 'Alumni' : '5th Semester',
      university: 'Riphah International University',
      department: 'Faculty of Computing & Information Technology',
      location: 'Sahiwal, Pakistan',
      cgpa: '—',
      skills: const [],
    );
  }

  List<ProjectOpportunity> activeOpportunities() =>
      opportunities
          .where((project) => project.status == ProjectOpportunityStatus.active)
          .toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<ProjectOpportunity> projectsCreatedBy(String creatorId) =>
      opportunities.where((project) => project.creatorId == creatorId).toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<ProjectOpportunity> projectsJoinedBy(String applicantId) {
    final projectIds = interests
        .where(
          (interest) =>
              interest.applicantId == applicantId &&
              interest.status == ProjectInterestStatus.accepted,
        )
        .map((interest) => interest.projectId)
        .toSet();
    return opportunities
        .where(
          (project) =>
              projectIds.contains(project.id) &&
              project.creatorId != applicantId,
        )
        .toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
  }

  List<ProjectInterest> interestsForProject(String projectId) =>
      interests.where((interest) => interest.projectId == projectId).toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<ProjectInterest> interestsByApplicant(String applicantId) =>
      interests
          .where((interest) => interest.applicantId == applicantId)
          .toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<ProjectInterest> interestsForProjectByStatus(
    String projectId,
    ProjectInterestStatus status,
  ) =>
      interestsForProject(projectId)
          .where((interest) => interest.status == status)
          .toList();

  int acceptedCount(String projectId) => interests
      .where(
        (interest) =>
            interest.projectId == projectId &&
            interest.status == ProjectInterestStatus.accepted,
      )
      .length;

  int memberCount(ProjectOpportunity project) => 1 + acceptedCount(project.id);

  int openSpots(ProjectOpportunity project) =>
      (project.desiredTeamSize - memberCount(project)).clamp(0, 1000000);

  bool isRecruiting(ProjectOpportunity project) =>
      project.status == ProjectOpportunityStatus.active &&
      openSpots(project) > 0;

  ProjectOpportunity? createProject({
    required UserProfileRole creatorRole,
    required String creatorId,
    required String title,
    required String description,
    required String category,
    required List<String> requiredSkills,
    required String teamRequirements,
    required int desiredTeamSize,
  }) {
    if (creatorRole == UserProfileRole.admin ||
        title.trim().isEmpty ||
        description.trim().isEmpty ||
        category.isEmpty ||
        requiredSkills.isEmpty ||
        teamRequirements.trim().isEmpty ||
        desiredTeamSize < 2) {
      return null;
    }

    final created = ProjectOpportunity(
      id: 'local-project-${_nextProjectNumber++}',
      creatorId: creatorId,
      title: title.trim(),
      description: description.trim(),
      category: category,
      requiredSkills: List.unmodifiable(requiredSkills),
      teamRequirements: teamRequirements.trim(),
      desiredTeamSize: desiredTeamSize,
      status: ProjectOpportunityStatus.active,
      createdAt: DateTime.now(),
    );
    opportunities.add(created);
    notifyListeners();
    return created;
  }

  bool updateProject({
    required String projectId,
    required String editorId,
    required String title,
    required String description,
    required String category,
    required List<String> requiredSkills,
    required String teamRequirements,
    required int desiredTeamSize,
  }) {
    final index = opportunities.indexWhere((item) => item.id == projectId);
    if (index < 0 ||
        opportunities[index].creatorId != editorId ||
        title.trim().isEmpty ||
        description.trim().isEmpty ||
        category.isEmpty ||
        requiredSkills.isEmpty ||
        teamRequirements.trim().isEmpty ||
        desiredTeamSize < memberCount(opportunities[index])) {
      return false;
    }
    opportunities[index] = opportunities[index].copyWith(
      title: title.trim(),
      description: description.trim(),
      category: category,
      requiredSkills: requiredSkills,
      teamRequirements: teamRequirements.trim(),
      desiredTeamSize: desiredTeamSize,
    );
    notifyListeners();
    return true;
  }

  bool closeProject({required String projectId, required String ownerId}) {
    final index = opportunities.indexWhere((item) => item.id == projectId);
    if (index < 0 || opportunities[index].creatorId != ownerId) return false;
    if (opportunities[index].status == ProjectOpportunityStatus.closed) {
      return false;
    }
    opportunities[index] = opportunities[index].copyWith(
      status: ProjectOpportunityStatus.closed,
    );
    notifyListeners();
    return true;
  }

  SubmitProjectResult submitInterest({
    required String projectId,
    required UserProfileRole applicantRole,
    required String applicantId,
    required String message,
    required List<String> selectedSkills,
    required String weeklyAvailability,
  }) {
    if (applicantRole != UserProfileRole.student &&
        applicantRole != UserProfileRole.senior) {
      return SubmitProjectResult.unauthorized;
    }
    final target = project(projectId);
    if (target == null) return SubmitProjectResult.notFound;
    if (applicantId == target.creatorId) {
      return SubmitProjectResult.unauthorized;
    }
    if (interest(projectId, applicantId) != null) {
      return SubmitProjectResult.duplicate;
    }
    if (target.status != ProjectOpportunityStatus.active) {
      return SubmitProjectResult.closed;
    }
    if (openSpots(target) == 0) return SubmitProjectResult.full;
    final applicant = userSummary(applicantId);
    if (message.trim().isEmpty ||
        selectedSkills.isEmpty ||
        selectedSkills.any((skill) => !applicant.skills.contains(skill))) {
      return SubmitProjectResult.invalidSkills;
    }

    interests.add(
      ProjectInterest(
        projectId: projectId,
        applicantId: applicantId,
        message: message.trim(),
        selectedSkills: List.unmodifiable(selectedSkills),
        weeklyAvailability: weeklyAvailability,
        status: ProjectInterestStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    final ownerRole = userSummary(target.creatorId).role;
    final recipientId = target.creatorId == userIdFor(ownerRole)
        ? NotificationAnnouncementStore.instance.userIdFor(ownerRole)
        : target.creatorId;
    NotificationAnnouncementStore.instance.addActivityNotification(
      recipientId: recipientId,
      type: 'Project application',
      message: 'A campus member submitted an interest for ${target.title}.',
    );
    notifyListeners();
    return SubmitProjectResult.created;
  }

  ProjectDecisionResult decideInterest({
    required String projectId,
    required String applicantId,
    required String ownerId,
    required ProjectInterestStatus decision,
  }) {
    if (decision == ProjectInterestStatus.pending) {
      return ProjectDecisionResult.alreadyProcessed;
    }
    final target = project(projectId);
    if (target == null) return ProjectDecisionResult.notFound;
    if (target.creatorId != ownerId) return ProjectDecisionResult.unauthorized;
    final index = interests.indexWhere(
      (interest) =>
          interest.projectId == projectId &&
          interest.applicantId == applicantId,
    );
    if (index < 0) return ProjectDecisionResult.notFound;
    if (interests[index].status != ProjectInterestStatus.pending) {
      return ProjectDecisionResult.alreadyProcessed;
    }
    if (decision == ProjectInterestStatus.accepted &&
        (target.status == ProjectOpportunityStatus.closed ||
            openSpots(target) == 0)) {
      return ProjectDecisionResult.full;
    }
    interests[index] = interests[index].copyWith(status: decision);
    notifyListeners();
    return ProjectDecisionResult.updated;
  }
}
