import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/project_interest.dart';
import '../services/project_collaboration_store.dart';
import '../widgets/project_widgets.dart';

class ProjectInterestDetailsScreen extends StatelessWidget {
  const ProjectInterestDetailsScreen({
    required this.viewerRole,
    required this.projectId,
    required this.applicantId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String projectId;
  final String applicantId;

  @override
  Widget build(BuildContext context) {
    final store = ProjectCollaborationStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final project = store.project(projectId);
        final interest = store.interest(projectId, applicantId);
        if (project == null || interest == null) {
          return ProjectScaffold(
            title: 'Interest Details',
            viewerRole: viewerRole,
            body: const ProjectEmptyState(
              title: 'Interest unavailable',
              message: 'This submission could not be found.',
              icon: Icons.search_off,
            ),
          );
        }

        final ownerId = store.userIdFor(viewerRole);
        final isOwner = project.creatorId == ownerId;
        if (!isOwner && applicantId != ownerId) {
          return ProjectScaffold(
            title: 'Interest Details',
            viewerRole: viewerRole,
            body: const ProjectEmptyState(
              title: 'Access unavailable',
              message: 'Only the project owner and the applicant can view this submission.',
              icon: Icons.lock_outline,
            ),
          );
        }
        final applicant = store.userSummary(
          applicantId,
          viewerRole: viewerRole,
        );
        final canAccept =
            isOwner &&
            interest.status == ProjectInterestStatus.pending &&
            store.isRecruiting(project);
        final canReject =
            isOwner && interest.status == ProjectInterestStatus.pending;

        return ProjectScaffold(
          title: 'Interest Details',
          viewerRole: viewerRole,
          bottom: canReject
              ? SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _decide(
                              context,
                              ProjectInterestStatus.rejected,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              minimumSize: const Size.fromHeight(48),
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: canAccept
                                ? () => _decide(
                                    context,
                                    ProjectInterestStatus.accepted,
                                  )
                                : null,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Accept Interest'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            children: [
              ProjectCardSurface(
                color: AppColors.paleBlue,
                child: Row(
                  children: [
                    const Icon(
                      Icons.rocket_launch_outlined,
                      color: AppColors.deepPrimary,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Project opportunity',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            project.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              ProjectCardSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProjectAvatar(applicant.name, radius: 27),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                applicant.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${applicant.roleLabel} • ${applicant.program}',
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '${applicant.semester} • ${applicant.department}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Interest Status',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ProjectStatusPill(
                      label: _statusLabel(interest.status),
                      color: _statusColor(interest.status),
                      textColor: _statusTextColor(interest.status),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Message to Project Owner',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              ProjectCardSurface(
                child: Text(
                  interest.message,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Relevant Skills',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 6,
                children: interest.selectedSkills
                    .map((skill) => ProjectPill(skill))
                    .toList(),
              ),
              const SizedBox(height: 14),
              ProjectCardSurface(
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      color: AppColors.deepPrimary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Weekly Availability',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      interest.weeklyAvailability,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isOwner && interest.status == ProjectInterestStatus.pending)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Your submission is awaiting review by the project owner.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (isOwner &&
                  interest.status == ProjectInterestStatus.pending &&
                  !store.isRecruiting(project))
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'This project cannot accept another team member.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _decide(BuildContext context, ProjectInterestStatus decision) {
    final result = ProjectCollaborationStore.instance.decideInterest(
      projectId: projectId,
      applicantId: applicantId,
      ownerId: ProjectCollaborationStore.instance.userIdFor(viewerRole),
      decision: decision,
    );
    if (result != ProjectDecisionResult.updated) {
      showProjectMessage(context, switch (result) {
        ProjectDecisionResult.unauthorized =>
          'Only the project owner can review this interest.',
        ProjectDecisionResult.full =>
          'No project places are available to accept this interest.',
        ProjectDecisionResult.alreadyProcessed =>
          'This interest has already been reviewed.',
        ProjectDecisionResult.notFound => 'This interest could not be found.',
        ProjectDecisionResult.updated => 'Interest updated.',
      }, isError: true);
      return;
    }
    Navigator.of(context).pop(true);
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
