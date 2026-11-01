import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/alumni_mentor.dart';
import '../models/mentorship_route_arguments.dart';
import '../models/mentorship_request.dart';
import '../services/mentorship_store.dart';
import '../widgets/mentorship_widgets.dart';

class AlumniProfileScreen extends StatelessWidget {
  const AlumniProfileScreen({
    required this.alumniId,
    required this.viewerRole,
    super.key,
  });

  final String alumniId;
  final UserProfileRole viewerRole;

  @override
  Widget build(BuildContext context) {
    final mentor = MentorshipStore.instance.mentorById(alumniId);
    if (mentor == null) {
      return MentorshipPage(
        title: 'Alumni Profile',
        child: const MentorshipEmptyState(
          title: 'Alumni profile unavailable',
          message: 'Return to the directory to choose another profile.',
        ),
      );
    }

    return MentorshipPage(
      title: 'Alumni Profile',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: [
          _identityCard(context, mentor),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'About',
            child: Text(
              mentor.bio,
              style: const TextStyle(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Education',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.school_outlined, color: AppColors.deepPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.degree,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        mentor.department,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Class of ${mentor.graduationYear}',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Skills & mentorship focus',
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                ...mentor.skills.map(MentorshipTag.new),
                ...mentor.focusAreas.map(MentorshipTag.new),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Professional experience',
            child: Column(
              children: mentor.experience
                  .map((item) => _experience(item))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: MentorshipStore.instance,
            builder: (context, _) => _requestSection(context, mentor),
          ),
        ],
      ),
    );
  }

  Widget _identityCard(BuildContext context, AlumniMentor mentor) =>
      MentorshipCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            MentorAvatar(mentor.name, radius: 39),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    mentor.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.verified, color: AppColors.success, size: 19),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              mentor.headline,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 4),
            Text(
              '${mentor.department} · Class of ${mentor.graduationYear}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _stat('${mentor.yearsExperience} yrs', 'Experience'),
                _stat('${mentor.menteesGuided}', 'Mentees'),
                _stat('${mentor.rating} ★', 'Rating'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 3),
                Text(
                  mentor.location,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _stat(String value, String label) => Container(
    constraints: const BoxConstraints(minWidth: 86),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.deepPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _sectionCard({required String title, required Widget child}) =>
      MentorshipCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );

  Widget _experience(AlumniExperience item) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.work_outline, color: AppColors.deepPrimary, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${item.company} · ${item.period}',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
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

  Widget _requestSection(BuildContext context, AlumniMentor mentor) {
    final store = MentorshipStore.instance;
    final viewerId = store.userIdFor(viewerRole);
    MentorshipRequest? existingRequest;
    if (viewerRole == UserProfileRole.student ||
        viewerRole == UserProfileRole.senior) {
      for (final request in store.sentRequests(viewerId)) {
        if (request.alumniId == mentor.id &&
            (request.status == MentorshipRequestStatus.pending ||
                request.status == MentorshipRequestStatus.accepted)) {
          existingRequest = request;
          break;
        }
      }
    }

    String? label;
    if (existingRequest?.status == MentorshipRequestStatus.pending) {
      label = 'View pending request';
    } else if (existingRequest?.status == MentorshipRequestStatus.accepted) {
      label = 'View active mentorship';
    } else if (!mentor.acceptsRequests) {
      label = 'Not accepting requests';
    } else {
      label = 'Request mentorship';
    }

    final eligible =
        viewerRole == UserProfileRole.student ||
        viewerRole == UserProfileRole.senior;
    return MentorshipCard(
      color: AppColors.paleBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interested in mentorship?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            mentor.acceptsRequests && mentor.openSpots > 0
                ? 'Accepting requests · ${mentor.openSpots} spots available'
                : 'This alumnus is not accepting mentorship requests.',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !eligible || !mentor.acceptsRequests
                  ? null
                  : existingRequest == null
                  ? () async {
                      final sent = await Navigator.of(context)
                          .pushNamed<dynamic>(
                            AppRoutes.mentorshipRequest,
                            arguments: MentorshipRouteArguments(
                              viewerRole: viewerRole,
                              alumniId: mentor.id,
                            ),
                          );
                      if (context.mounted && sent == true) {
                        showMentorshipMessage(
                          context,
                          'Mentorship request sent.',
                        );
                      }
                    }
                  : () {
                      if (existingRequest?.status ==
                          MentorshipRequestStatus.accepted) {
                        openActiveMentorships(context, role: viewerRole);
                      } else {
                        openMentorshipRequests(context, role: viewerRole);
                      }
                    },
              icon: Icon(
                existingRequest?.status == MentorshipRequestStatus.accepted
                    ? Icons.handshake_outlined
                    : Icons.send_outlined,
              ),
              label: Text(eligible ? label : 'Alumni mentorship profile'),
            ),
          ),
        ],
      ),
    );
  }
}
