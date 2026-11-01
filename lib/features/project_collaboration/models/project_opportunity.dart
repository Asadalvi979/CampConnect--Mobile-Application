enum ProjectOpportunityStatus { active, closed }

class ProjectOpportunity {
  const ProjectOpportunity({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredSkills,
    required this.teamRequirements,
    required this.desiredTeamSize,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String category;
  final List<String> requiredSkills;
  final String teamRequirements;
  final int desiredTeamSize;
  final ProjectOpportunityStatus status;
  final DateTime createdAt;

  ProjectOpportunity copyWith({
    String? title,
    String? description,
    String? category,
    List<String>? requiredSkills,
    String? teamRequirements,
    int? desiredTeamSize,
    ProjectOpportunityStatus? status,
  }) => ProjectOpportunity(
    id: id,
    creatorId: creatorId,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    requiredSkills: List.unmodifiable(requiredSkills ?? this.requiredSkills),
    teamRequirements: teamRequirements ?? this.teamRequirements,
    desiredTeamSize: desiredTeamSize ?? this.desiredTeamSize,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}
