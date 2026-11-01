enum ProjectInterestStatus { pending, accepted, rejected }

class ProjectInterest {
  const ProjectInterest({
    required this.projectId,
    required this.applicantId,
    required this.message,
    required this.selectedSkills,
    required this.weeklyAvailability,
    required this.status,
    required this.createdAt,
  });

  final String projectId;
  final String applicantId;
  final String message;
  final List<String> selectedSkills;
  final String weeklyAvailability;
  final ProjectInterestStatus status;
  final DateTime createdAt;

  ProjectInterest copyWith({ProjectInterestStatus? status}) => ProjectInterest(
    projectId: projectId,
    applicantId: applicantId,
    message: message,
    selectedSkills: List.unmodifiable(selectedSkills),
    weeklyAvailability: weeklyAvailability,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}
