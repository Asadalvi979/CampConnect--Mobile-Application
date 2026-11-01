import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/mentorship_request.dart';
import '../services/mentorship_store.dart';
import '../widgets/mentorship_widgets.dart';

class MentorshipRequestDetailsScreen extends StatelessWidget {
  const MentorshipRequestDetailsScreen({
    required this.requestId,
    required this.viewerRole,
    super.key,
  });

  final String requestId;
  final UserProfileRole viewerRole;

  @override
  Widget build(BuildContext context) {
    final store = MentorshipStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final request = store.requestById(requestId);
        if (request == null) {
          return MentorshipPage(
            title: 'Request Details',
            child: const MentorshipEmptyState(
              title: 'Request not found',
              message: 'This request may no longer be available.',
            ),
          );
        }

        final requester = store.memberFor(
          request.requesterId,
          currentViewerRole: viewerRole,
        );
        final mentor = store.mentorById(request.alumniId);
        if (mentor == null) {
          return MentorshipPage(
            title: 'Request Details',
            child: const MentorshipEmptyState(
              title: 'Alumni profile unavailable',
              message: 'The associated alumni profile is unavailable.',
            ),
          );
        }
        final canDecide =
            viewerRole == UserProfileRole.alumni &&
            store.userIdFor(viewerRole) == request.alumniId &&
            request.status == MentorshipRequestStatus.pending;

        return MentorshipPage(
          title: 'Request Details',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            children: [
              MentorshipCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mentorship request',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        MentorshipStatusTag(_statusLabel(request.status)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submitted ${_dateLabel(request.createdAt)}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(height: 24),
                    _personRow(
                      context,
                      label: 'REQUESTER',
                      name: requester.name,
                      subtitle:
                          '${requester.roleLabel} · ${requester.program} · ${requester.semester}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Icon(
                        Icons.arrow_downward,
                        color: AppColors.deepPrimary,
                        size: 19,
                      ),
                    ),
                    _personRow(
                      context,
                      label: 'ALUMNI MENTOR',
                      name: mentor.name,
                      subtitle: mentor.headline,
                    ),
                    const Divider(height: 24),
                    _detailRow('Mentorship area', request.focusArea),
                    _detailRow('Preferred cadence', request.cadence),
                    const SizedBox(height: 14),
                    const Text(
                      'Personal message',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.message,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    if (request.respondedAt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Updated ${_dateLabel(request.respondedAt!)}',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (request.status == MentorshipRequestStatus.accepted) ...[
                const SizedBox(height: 12),
                MentorshipCard(
                  color: AppColors.paleBlue,
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_outlined, color: AppColors.success),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'This request was accepted. Mentorship communication is authorized independently of Friendship.',
                          style: TextStyle(fontSize: 12, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (canDecide) ...[
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _respond(context, store, accepted: false),
                        child: const Text('Reject request'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            _respond(context, store, accepted: true),
                        child: const Text('Accept request'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _personRow(
    BuildContext context, {
    required String label,
    required String name,
    required String subtitle,
  }) => Row(
    children: [
      MentorAvatar(name, radius: 25),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
                letterSpacing: 0.6,
              ),
            ),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );

  void _respond(
    BuildContext context,
    MentorshipStore store, {
    required bool accepted,
  }) {
    final success = accepted
        ? store.acceptRequest(
            requestId: requestId,
            viewerRole: viewerRole,
            viewerId: store.userIdFor(viewerRole),
          )
        : store.rejectRequest(
            requestId: requestId,
            viewerRole: viewerRole,
            viewerId: store.userIdFor(viewerRole),
          );
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      showMentorshipMessage(
        context,
        'This request can no longer be updated.',
        isError: true,
      );
    }
  }

  String _statusLabel(MentorshipRequestStatus status) => switch (status) {
    MentorshipRequestStatus.pending => 'Pending',
    MentorshipRequestStatus.accepted => 'Accepted',
    MentorshipRequestStatus.rejected => 'Rejected',
    MentorshipRequestStatus.cancelled => 'Cancelled',
  };

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
