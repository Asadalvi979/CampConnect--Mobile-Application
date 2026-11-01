import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/project_interest.dart';
import '../models/project_opportunity.dart';
import '../models/project_route_arguments.dart';
import '../services/project_collaboration_store.dart';
import '../widgets/project_widgets.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  Widget build(BuildContext context) {
    final store = ProjectCollaborationStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final userId = store.userIdFor(viewerRole);
        final created = store.projectsCreatedBy(userId);
        final joined = store.projectsJoinedBy(userId);
        final interests = store.interestsByApplicant(userId);
        return ProjectScaffold(
          title: 'My Projects',
          viewerRole: viewerRole,
          showBottomBar: true,
          actions: [
            IconButton(
              tooltip: 'Create project',
              onPressed: () => openProjectCreate(context, viewerRole),
              icon: const Icon(Icons.add),
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            children: [
              _sectionTitle(
                'Projects I Created',
                created.length,
                icon: Icons.create_new_folder_outlined,
              ),
              if (created.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                  child: ProjectCardSurface(
                    child: Text(
                      'You have not created a project opportunity yet.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                for (final project in created) ...[
                  const SizedBox(height: 8),
                  _projectCard(context, store, project, isOwner: true),
                ],
              const SizedBox(height: 20),
              _sectionTitle(
                'Projects I Joined',
                joined.length,
                icon: Icons.groups_outlined,
              ),
              if (joined.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                  child: ProjectCardSurface(
                    child: Text(
                      'Accepted project memberships will appear here.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                for (final project in joined) ...[
                  const SizedBox(height: 8),
                  _projectCard(context, store, project, isOwner: false),
                ],
              const SizedBox(height: 20),
              _sectionTitle(
                'My Interest Submissions',
                interests.length,
                icon: Icons.outgoing_mail,
              ),
              if (interests.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: ProjectCardSurface(
                    child: Text(
                      'Your submissions and their review statuses will appear here.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                for (final interest in interests) ...[
                  const SizedBox(height: 8),
                  _interestCard(context, store, interest),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, int count, {required IconData icon}) =>
      Row(
        children: [
          Icon(icon, size: 19, color: AppColors.deepPrimary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ProjectPill('$count'),
        ],
      );

  Widget _projectCard(
    BuildContext context,
    ProjectCollaborationStore store,
    ProjectOpportunity project, {
    required bool isOwner,
  }) => ProjectCardSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: ProjectPill(project.category)),
            ProjectStatusPill(
              label: _projectStatus(project, store),
              color: store.isRecruiting(project)
                  ? const Color(0xFFB7F7DA)
                  : const Color(0xFFE2E8F0),
              textColor: store.isRecruiting(project)
                  ? AppColors.success
                  : AppColors.secondaryText,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          project.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          project.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ProjectPill(
              '${store.memberCount(project)}/${project.desiredTeamSize} members',
            ),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  openProjectDetails(context, viewerRole, project.id),
              child: const Text('View'),
            ),
          ],
        ),
        if (isOwner) ...[
          const Divider(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      openProjectInterests(context, viewerRole, project.id),
                  icon: const Icon(Icons.people_outline, size: 17),
                  label: Text(
                    'Interests (${store.interestsForProject(project.id).length})',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Edit project',
                onPressed: () =>
                    openProjectEdit(context, viewerRole, project.id),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  Widget _interestCard(
    BuildContext context,
    ProjectCollaborationStore store,
    ProjectInterest interest,
  ) {
    final project = store.project(interest.projectId);
    if (project == null) return const SizedBox.shrink();
    return ProjectCardSurface(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.projectInterestDetails,
          arguments: ProjectRouteArguments(
            viewerRole: viewerRole,
            projectId: interest.projectId,
            applicantId: interest.applicantId,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ProjectStatusPill(
                  label: _interestStatus(interest.status),
                  color: _statusColor(interest.status),
                  textColor: _statusTextColor(interest.status),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              interest.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${interest.selectedSkills.join(' • ')}  |  ${interest.weeklyAvailability}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.deepPrimary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _projectStatus(
    ProjectOpportunity project,
    ProjectCollaborationStore store,
  ) {
    if (project.status == ProjectOpportunityStatus.closed) return 'Closed';
    if (store.isRecruiting(project)) return 'Recruiting';
    return 'Active';
  }

  String _interestStatus(ProjectInterestStatus status) => switch (status) {
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
}
