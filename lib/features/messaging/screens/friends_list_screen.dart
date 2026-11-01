import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mentorship/services/mentorship_store.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/messaging_route_arguments.dart';
import '../services/messaging_store.dart';
import '../widgets/messaging_navigation.dart';
import '../widgets/messaging_widgets.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MessagingStore.instance;
    final viewerId = store.currentUserId(widget.viewerRole);
    final mentorshipStore = MentorshipStore.instance;
    return MessagingPage(
      title: 'Friends',
      actions: [
        IconButton(
          tooltip: 'Friend requests',
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.messageFriendRequests,
            arguments: MessagingRouteArguments(viewerRole: widget.viewerRole),
          ),
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
      ],
      child: AnimatedBuilder(
        animation: Listenable.merge([store, mentorshipStore]),
        builder: (context, _) {
          final friendIds = store.friendsFor(viewerId).where((id) {
            final contact = store.contactFor(id);
            return _matchesQuery(contact.name, contact.headline);
          }).toList();
          final relationships = mentorshipStore
              .activeMentorshipsFor(viewerId)
              .where((relationship) {
                final request = mentorshipStore.requestById(
                  relationship.requestId,
                );
                if (request == null) return false;
                final peerId = request.requesterId == viewerId
                    ? request.alumniId
                    : request.requesterId;
                final peer = store.contactFor(peerId);
                return _matchesQuery(peer.name, peer.headline);
              })
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 7),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search friends',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
                  children: [
                    MessagingSectionLabel('Friends · ${friendIds.length}'),
                    if (friendIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: MessagingEmptyState(
                          title: 'No friends found',
                          message: 'Active friends will appear here.',
                          icon: Icons.people_outline,
                        ),
                      )
                    else
                      for (final friendId in friendIds)
                        _contactTile(
                          store,
                          friendId,
                          'Friend',
                          onMessage: () => openFriendConversation(
                            context,
                            viewerRole: widget.viewerRole,
                            peerId: friendId,
                          ),
                        ),
                    MessagingSectionLabel(
                      'Mentorship connections · ${relationships.length}',
                    ),
                    if (relationships.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        child: Text(
                          'Accepted mentorship connections appear here.',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      for (final relationship in relationships)
                        _mentorshipTile(
                          store,
                          mentorshipStore,
                          viewerId,
                          relationship.requestId,
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _matchesQuery(String name, String headline) {
    final query = _searchController.text.trim().toLowerCase();
    return query.isEmpty ||
        name.toLowerCase().contains(query) ||
        headline.toLowerCase().contains(query);
  }

  Widget _contactTile(
    MessagingStore store,
    String id,
    String relationship, {
    required VoidCallback onMessage,
  }) {
    final contact = store.contactFor(id);
    return ListTile(
      leading: MessagingAvatar(contact: contact),
      title: Text(contact.name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        '${contact.roleLabel} · $relationship',
        style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
      ),
      trailing: IconButton(
        tooltip: 'Message ${contact.name}',
        onPressed: onMessage,
        icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
      ),
    );
  }

  Widget _mentorshipTile(
    MessagingStore store,
    MentorshipStore mentorshipStore,
    String viewerId,
    String requestId,
  ) {
    final request = mentorshipStore.requestById(requestId);
    if (request == null) return const SizedBox.shrink();
    final peerId = request.requesterId == viewerId
        ? request.alumniId
        : request.requesterId;
    return _contactTile(
      store,
      peerId,
      'Accepted mentorship',
      onMessage: () => openMentorshipConversation(
        context,
        viewerRole: widget.viewerRole,
        requestId: requestId,
      ),
    );
  }
}
