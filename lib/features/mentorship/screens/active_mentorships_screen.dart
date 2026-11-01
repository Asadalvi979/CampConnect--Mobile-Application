import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../models/mentorship.dart';
import '../models/mentorship_request.dart';
import '../services/mentorship_store.dart';
import '../widgets/mentorship_widgets.dart';

class ActiveMentorshipsScreen extends StatefulWidget {
  const ActiveMentorshipsScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<ActiveMentorshipsScreen> createState() =>
      _ActiveMentorshipsScreenState();
}

class _ActiveMentorshipsScreenState extends State<ActiveMentorshipsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final store = MentorshipStore.instance;
    final viewerId = store.userIdFor(widget.viewerRole);
    return MentorshipPage(
      title: 'Active Mentorships',
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final relationships = store
              .activeMentorshipsFor(viewerId)
              .where((relationship) => _matches(relationship, store))
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your mentorship connections',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Accepted mentorship requests appear here.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      children: [
                        _filterChip('All'),
                        _filterChip('As a mentee'),
                        _filterChip('As a mentor'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: relationships.isEmpty
                    ? const MentorshipEmptyState(
                        title: 'No active mentorships',
                        message:
                            'An accepted mentorship request will appear here.',
                        icon: Icons.people_outline,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 2, 18, 22),
                        itemCount: relationships.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _relationshipCard(
                          context,
                          store,
                          relationships[index],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _matches(Mentorship relationship, MentorshipStore store) {
    final request = store.requestById(relationship.requestId);
    if (request == null) return false;
    return switch (_filter) {
      'As a mentee' =>
        request.requesterId == store.userIdFor(widget.viewerRole),
      'As a mentor' => request.alumniId == store.userIdFor(widget.viewerRole),
      _ => true,
    };
  }

  Widget _filterChip(String label) {
    final selected = _filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = label),
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.deepPrimary,
        fontSize: 11,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.lightBlue,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _relationshipCard(
    BuildContext context,
    MentorshipStore store,
    Mentorship relationship,
  ) {
    final request = store.requestById(relationship.requestId);
    if (request == null || request.status != MentorshipRequestStatus.accepted) {
      return const SizedBox.shrink();
    }
    final isRequester =
        request.requesterId == store.userIdFor(widget.viewerRole);
    final mentor = store.mentorById(request.alumniId);
    if (mentor == null) return const SizedBox.shrink();
    final peerName = isRequester
        ? mentor.name
        : store
              .memberFor(
                request.requesterId,
                currentViewerRole: widget.viewerRole,
              )
              .name;
    final peerHeadline = isRequester
        ? mentor.headline
        : store
              .memberFor(
                request.requesterId,
                currentViewerRole: widget.viewerRole,
              )
              .roleLabel;

    return MentorshipCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MentorAvatar(peerName, radius: 25),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      peerHeadline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const MentorshipStatusTag('Active'),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              MentorshipTag(request.focusArea),
              MentorshipTag(request.cadence),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openMentorshipRequestDetails(
                    context,
                    role: widget.viewerRole,
                    requestId: request.id,
                  ),
                  icon: const Icon(Icons.info_outline, size: 17),
                  label: const Text('Details'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => openMentorshipConversation(
                    context,
                    viewerRole: widget.viewerRole,
                    requestId: request.id,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 17),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
