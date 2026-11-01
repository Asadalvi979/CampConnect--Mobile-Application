import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/project_interest.dart';
import '../models/project_opportunity.dart';
import '../models/project_route_arguments.dart';
import '../models/project_user_summary.dart';
import '../services/project_collaboration_store.dart';
import '../widgets/project_widgets.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({
    required this.projectId,
    required this.viewerRole,
    super.key,
  });

  final String projectId;
  final UserProfileRole viewerRole;

  @override
  Widget build(BuildContext context) {
    final store = ProjectCollaborationStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final project = store.project(projectId);
        if (project == null) {
          return ProjectScaffold(
            title: 'Project Details',
            viewerRole: viewerRole,
            body: const ProjectEmptyState(
              title: 'Project unavailable',
              message: 'This opportunity may have been removed.',
            ),
          );
        }

        final viewerId = store.userIdFor(viewerRole);
        final isOwner = project.creatorId == viewerId;
        final existingInterest = store.interest(project.id, viewerId);
        final owner = store.userSummary(
          project.creatorId,
          viewerRole: viewerRole,
        );
        final interests = store.interestsForProject(project.id);
        final accepted = interests
            .where(
              (interest) => interest.status == ProjectInterestStatus.accepted,
            )
            .toList();
        final teamCount = store.memberCount(project);
        final spots = store.openSpots(project);

        return ProjectScaffold(
          title: 'Project Details',
          viewerRole: viewerRole,
          actions: isOwner
              ? [
                  IconButton(
                    tooltip: 'Edit project',
                    onPressed: () async {
                      final changed = await Navigator.of(context)
                          .pushNamed<dynamic>(
                            AppRoutes.projectEdit,
                            arguments: ProjectRouteArguments(
                              viewerRole: viewerRole,
                              projectId: project.id,
                            ),
                          );
                      if (context.mounted && changed == true) {
                        showProjectMessage(context, 'Project updated locally.');
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ]
              : const [],
          bottom: _bottomActions(
            context,
            store,
            project,
            isOwner: isOwner,
            existingInterest: existingInterest,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            children: [
              _hero(project, store, spots),
              const SizedBox(height: 13),
              ProjectCardSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    _creatorRow(owner, project),
                    const SizedBox(height: 13),
                    Text(
                      project.description,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              _sectionTitle(
                Icons.terminal_outlined,
                'Required Technical Skills',
                trailing: '${project.requiredSkills.length} competencies',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: project.requiredSkills
                    .map(
                      (skill) => ProjectPill(
                        '•  $skill',
                        color: AppColors.lightBlue,
                        textColor: AppColors.primaryText,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              _sectionTitle(Icons.handshake_outlined, 'Collaboration Scope'),
              const SizedBox(height: 8),
              _scopeCard(
                icon: Icons.flag_outlined,
                title: 'Project Objective',
                content: project.description,
              ),
              const SizedBox(height: 8),
              _scopeCard(
                icon: Icons.volunteer_activism_outlined,
                title: 'Team Requirements & Roles Needed',
                content: project.teamRequirements,
              ),
              const SizedBox(height: 8),
              _scopeCard(
                icon: Icons.groups_outlined,
                title: 'Team Requirements',
                content:
                    '$teamCount of ${project.desiredTeamSize} team members. ${spots > 0 ? '$spots open ${spots == 1 ? 'place' : 'places'}.' : 'No open places.'}',
              ),
              const SizedBox(height: 18),
              _sectionTitle(
                Icons.people_outline,
                'Current Team ($teamCount/${project.desiredTeamSize})',
                trailing: spots > 0 ? '$spots Open' : 'Team Full',
              ),
              const SizedBox(height: 8),
              _teamMember(context, owner, isLead: true),
              for (final interest in accepted) ...[
                const SizedBox(height: 7),
                _teamMember(
                  context,
                  store.userSummary(
                    interest.applicantId,
                    viewerRole: viewerRole,
                  ),
                  isLead: false,
                ),
              ],
              if (spots > 0 &&
                  project.status == ProjectOpportunityStatus.active)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ProjectCardSurface(
                    color: AppColors.paleBlue,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_add_alt_1_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            '$spots open ${spots == 1 ? 'role' : 'roles'} · ${project.teamRequirements}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const ProjectPill('Open'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (existingInterest != null && !isOwner)
                ProjectCardSurface(
                  color: AppColors.paleBlue,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.deepPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your interest is ${_statusLabel(existingInterest.status).toLowerCase()}.',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ProjectStatusPill(
                        label: _statusLabel(existingInterest.status),
                        color: _statusColor(existingInterest.status),
                        textColor: _statusTextColor(existingInterest.status),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _hero(
    ProjectOpportunity project,
    ProjectCollaborationStore store,
    int spots,
  ) => Container(
    height: 140,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.deepPrimary, AppColors.primary],
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Stack(
      children: [
        const Positioned(
          right: 12,
          bottom: -7,
          child: Icon(
            Icons.rocket_launch_outlined,
            size: 130,
            color: Color(0x33FFFFFF),
          ),
        ),
        Positioned(
          left: 14,
          top: 12,
          child: ProjectPill(project.category, color: AppColors.white),
        ),
        Positioned(
          left: 14,
          bottom: 12,
          child: ProjectStatusPill(
            label: store.isRecruiting(project)
                ? 'Recruiting · $spots open'
                : _projectStatus(project, store),
            color: store.isRecruiting(project)
                ? const Color(0xFFB7F7DA)
                : AppColors.white,
            textColor: AppColors.deepPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _creatorRow(ProjectUserSummary owner, ProjectOpportunity project) =>
      Row(
        children: [
          ProjectAvatar(owner.name, radius: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${owner.roleLabel} • ${owner.semester}',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _createdLabel(project.createdAt),
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      );

  Widget _sectionTitle(IconData icon, String title, {String? trailing}) => Row(
    children: [
      Icon(icon, size: 19, color: AppColors.deepPrimary),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      if (trailing != null)
        Text(
          trailing,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 10),
        ),
    ],
  );

  Widget _scopeCard({
    required IconData icon,
    required String title,
    required String content,
  }) => ProjectCardSurface(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.deepPrimary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                content,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _teamMember(
    BuildContext context,
    ProjectUserSummary member, {
    required bool isLead,
  }) => ProjectCardSurface(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        ProjectAvatar(member.name, radius: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (isLead) ...[
                    const SizedBox(width: 6),
                    const ProjectPill('Lead'),
                  ],
                ],
              ),
              Text(
                '${member.roleLabel} • ${member.program} • ${member.semester}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Team chat',
          onPressed: () => showProjectMessage(
            context,
            'Messaging module will be available soon.',
          ),
          icon: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.deepPrimary,
            size: 19,
          ),
        ),
      ],
    ),
  );

  Widget _bottomActions(
    BuildContext context,
    ProjectCollaborationStore store,
    ProjectOpportunity project, {
    required bool isOwner,
    required ProjectInterest? existingInterest,
  }) {
    final isRecruiting = store.isRecruiting(project);
    final label = switch (existingInterest?.status) {
      ProjectInterestStatus.pending => 'Interest Pending',
      ProjectInterestStatus.accepted => 'Accepted to Team',
      ProjectInterestStatus.rejected => 'Interest Rejected',
      null => isOwner ? 'Manage Interests' : 'Express Interest',
    };
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: isOwner
                    ? () =>
                          openProjectInterests(context, viewerRole, project.id)
                    : existingInterest == null && isRecruiting
                    ? () => _sendInterest(context, project)
                    : null,
                icon: Icon(
                  isOwner ? Icons.manage_accounts_outlined : Icons.front_hand,
                ),
                label: Text(
                  isOwner
                      ? '$label (${store.interestsForProjectByStatus(project.id, ProjectInterestStatus.pending).length} Pending)'
                      : label,
                ),
              ),
            ),
            if (isOwner) ...[
              const SizedBox(height: 7),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.projectEdit,
                  arguments: ProjectRouteArguments(
                    viewerRole: viewerRole,
                    projectId: project.id,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Project'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendInterest(
    BuildContext context,
    ProjectOpportunity project,
  ) async {
    final result = await Navigator.of(context).pushNamed<dynamic>(
      AppRoutes.projectExpressInterest,
      arguments: ProjectRouteArguments(
        viewerRole: viewerRole,
        projectId: project.id,
      ),
    );
    if (context.mounted && result == true) {
      showProjectMessage(context, 'Project interest submitted.');
    }
  }

  String _projectStatus(
    ProjectOpportunity project,
    ProjectCollaborationStore store,
  ) {
    if (project.status == ProjectOpportunityStatus.closed) return 'Closed';
    return store.openSpots(project) == 0 ? 'Active · Team Full' : 'Active';
  }

  String _statusLabel(ProjectInterestStatus status) => switch (status) {
    ProjectInterestStatus.pending => 'Pending',
    ProjectInterestStatus.accepted => 'Accepted',
    ProjectInterestStatus.rejected => 'Rejected',
  };

  Color _statusColor(ProjectInterestStatus status) => switch (status) {
    ProjectInterestStatus.pending => const Color(0xFFFFF1C2),
    ProjectInterestStatus.accepted => const Color(0xFFB7F7DA),
    ProjectInterestStatus.rejected => const Color(0xFFFFE4E4),
  };

  Color _statusTextColor(ProjectInterestStatus status) => switch (status) {
    ProjectInterestStatus.pending => const Color(0xFF815300),
    ProjectInterestStatus.accepted => AppColors.success,
    ProjectInterestStatus.rejected => AppColors.error,
  };

  String _createdLabel(DateTime date) {
    final age = DateTime.now().difference(date).inDays;
    if (age <= 0) return 'Today';
    if (age == 1) return '1 day ago';
    return '$age days ago';
  }
}
