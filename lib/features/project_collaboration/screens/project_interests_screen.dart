import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/project_interest.dart';
import '../models/project_route_arguments.dart';
import '../services/project_collaboration_store.dart';
import '../widgets/project_widgets.dart';

class ProjectInterestsScreen extends StatelessWidget {
  const ProjectInterestsScreen({
    required this.viewerRole,
    required this.projectId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final store = ProjectCollaborationStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final project = store.project(projectId);
        final viewerId = store.userIdFor(viewerRole);
        if (project == null || project.creatorId != viewerId) {
          return ProjectScaffold(
            title: 'Project Interests',
            viewerRole: viewerRole,
            body: const ProjectEmptyState(
              title: 'Access unavailable',
              message:
                  'Only the project owner can review interest submissions.',
              icon: Icons.lock_outline,
            ),
          );
        }

        final interests = store.interestsForProject(project.id);
        return ProjectScaffold(
          title: 'Project Interests',
          viewerRole: viewerRole,
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                  child: ProjectCardSurface(
                    color: AppColors.paleBlue,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.rocket_launch_outlined,
                          color: AppColors.deepPrimary,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            project.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ProjectPill(
                          '${store.memberCount(project)}/${project.desiredTeamSize}',
                        ),
                      ],
                    ),
                  ),
                ),
                TabBar(
                  labelColor: AppColors.deepPrimary,
                  unselectedLabelColor: AppColors.secondaryText,
                  tabs: [
                    Tab(text: 'All (${interests.length})'),
                    Tab(
                      text:
                          'Pending (${store.interestsForProjectByStatus(project.id, ProjectInterestStatus.pending).length})',
                    ),
                    Tab(
                      text:
                          'Reviewed (${interests.where((item) => item.status != ProjectInterestStatus.pending).length})',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _interestList(interests, store),
                      _interestList(
                        interests
                            .where(
                              (item) =>
                                  item.status == ProjectInterestStatus.pending,
                            )
                            .toList(),
                        store,
                      ),
                      _interestList(
                        interests
                            .where(
                              (item) =>
                                  item.status != ProjectInterestStatus.pending,
                            )
                            .toList(),
                        store,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _interestList(
    List<ProjectInterest> interests,
    ProjectCollaborationStore store,
  ) {
    if (interests.isEmpty) {
      return const ProjectEmptyState(
        title: 'No interests yet',
        message: 'New project interest submissions will appear here.',
        icon: Icons.inbox_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 20),
      itemCount: interests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final interest = interests[index];
        final applicant = store.userSummary(
          interest.applicantId,
          viewerRole: viewerRole,
        );
        return ProjectCardSurface(
          padding: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.projectInterestDetails,
              arguments: ProjectRouteArguments(
                viewerRole: viewerRole,
                projectId: projectId,
                applicantId: interest.applicantId,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProjectAvatar(applicant.name),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              applicant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${applicant.roleLabel} • ${applicant.program}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ProjectStatusPill(
                        label: _statusLabel(interest.status),
                        color: _statusColor(interest.status),
                        textColor: _statusTextColor(interest.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    interest.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: interest.selectedSkills
                        .take(4)
                        .map((skill) => ProjectPill(skill))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 15,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          interest.weeklyAvailability,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'View details',
                        style: TextStyle(
                          color: AppColors.deepPrimary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
}
