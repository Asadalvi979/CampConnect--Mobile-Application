import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/mentorship_route_arguments.dart';
import '../models/mentorship_request.dart';
import '../services/mentorship_store.dart';
import '../widgets/mentorship_widgets.dart';

class MentorshipRequestsScreen extends StatelessWidget {
  const MentorshipRequestsScreen({
    required this.viewerRole,
    required this.initialTab,
    super.key,
  });

  final UserProfileRole viewerRole;
  final int initialTab;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    initialIndex: initialTab.clamp(0, 1),
    child: MentorshipPage(
      title: 'Mentorship Requests',
      actions: [
        IconButton(
          tooltip: 'Active mentorships',
          onPressed: () => openActiveMentorships(context, role: viewerRole),
          icon: const Icon(Icons.handshake_outlined),
        ),
      ],
      bottom: const TabBar(
        tabs: [
          Tab(text: 'Sent'),
          Tab(text: 'Incoming'),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Text(
              viewerRole == UserProfileRole.alumni
                  ? 'Review requests from students and seniors.'
                  : 'Track the mentorship requests you have sent.',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _RequestList(viewerRole: viewerRole, incoming: false),
                _RequestList(viewerRole: viewerRole, incoming: true),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.viewerRole, required this.incoming});

  final UserProfileRole viewerRole;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    final store = MentorshipStore.instance;
    final viewerId = store.userIdFor(viewerRole);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final requests = incoming
            ? viewerRole == UserProfileRole.alumni
                  ? store.receivedRequests(viewerId)
                  : const <MentorshipRequest>[]
            : store.sentRequests(viewerId);
        if (requests.isEmpty) {
          return MentorshipEmptyState(
            title: incoming
                ? viewerRole == UserProfileRole.alumni
                      ? 'No incoming requests'
                      : 'Alumni receive mentorship requests'
                : 'No requests sent yet',
            message: incoming
                ? viewerRole == UserProfileRole.alumni
                      ? 'New student and senior requests will appear here.'
                      : 'You can find alumni mentors in the directory.'
                : 'Explore the alumni directory when you are ready to connect.',
            icon: incoming ? Icons.inbox_outlined : Icons.send_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 3, 18, 22),
          itemCount: requests.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) =>
              _requestCard(context, requests[index], viewerId),
        );
      },
    );
  }

  Widget _requestCard(
    BuildContext context,
    MentorshipRequest request,
    String viewerId,
  ) {
    final store = MentorshipStore.instance;
    final member = incoming
        ? store.memberFor(request.requesterId, currentViewerRole: viewerRole)
        : null;
    final mentor = incoming ? null : store.mentorById(request.alumniId);
    final personName = member?.name ?? mentor?.name;
    if (personName == null) return const SizedBox.shrink();

    return MentorshipCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MentorAvatar(personName, radius: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      member != null
                          ? '${member.roleLabel} · ${member.program}'
                          : mentor?.headline ?? 'Alumni mentor',
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
              MentorshipStatusTag(_statusLabel(request.status)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              MentorshipTag(request.focusArea),
              MentorshipTag(request.cadence),
              MentorshipTag(_dateLabel(request.createdAt)),
            ],
          ),
          const SizedBox(height: 7),
          if (incoming && request.status == MentorshipRequestStatus.pending)
            _incomingActions(context, request, viewerId)
          else
            Row(
              children: [
                TextButton(
                  onPressed: () => _openDetails(context, request.id),
                  child: const Text('View details'),
                ),
                const Spacer(),
                if (!incoming &&
                    request.status == MentorshipRequestStatus.pending)
                  TextButton(
                    onPressed: () => _cancel(context, request.id, viewerId),
                    child: const Text('Withdraw request'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _incomingActions(
    BuildContext context,
    MentorshipRequest request,
    String viewerId,
  ) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    children: [
      TextButton(
        onPressed: () => _openDetails(context, request.id),
        child: const Text('Details'),
      ),
      TextButton(
        onPressed: () =>
            _respond(context, request.id, viewerId, accepted: false),
        child: const Text('Reject'),
      ),
      const SizedBox(width: 4),
      FilledButton(
        onPressed: () =>
            _respond(context, request.id, viewerId, accepted: true),
        child: const Text('Accept'),
      ),
    ],
  );

  Future<void> _openDetails(BuildContext context, String requestId) async {
    final changed = await Navigator.of(context).pushNamed<dynamic>(
      AppRoutes.mentorshipRequestDetails,
      arguments: MentorshipRouteArguments(
        viewerRole: viewerRole,
        requestId: requestId,
      ),
    );
    if (context.mounted && changed == true) {
      showMentorshipMessage(context, 'Request status updated.');
    }
  }

  void _respond(
    BuildContext context,
    String requestId,
    String viewerId, {
    required bool accepted,
  }) {
    final store = MentorshipStore.instance;
    final success = accepted
        ? store.acceptRequest(
            requestId: requestId,
            viewerRole: viewerRole,
            viewerId: viewerId,
          )
        : store.rejectRequest(
            requestId: requestId,
            viewerRole: viewerRole,
            viewerId: viewerId,
          );
    showMentorshipMessage(
      context,
      success
          ? accepted
                ? 'Mentorship request accepted.'
                : 'Mentorship request rejected.'
          : 'This request can no longer be updated.',
      isError: !success,
    );
  }

  void _cancel(BuildContext context, String requestId, String viewerId) {
    final cancelled = MentorshipStore.instance.cancelRequest(
      requestId: requestId,
      requesterId: viewerId,
    );
    showMentorshipMessage(
      context,
      cancelled ? 'Pending request withdrawn.' : 'Request cannot be withdrawn.',
      isError: !cancelled,
    );
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
