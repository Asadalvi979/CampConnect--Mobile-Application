import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mentorship/services/mentorship_store.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/messaging_conversation.dart';
import '../models/messaging_route_arguments.dart';
import '../services/messaging_store.dart';
import '../widgets/messaging_widgets.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MessagingStore.instance;
    final viewerId = store.currentUserId(widget.viewerRole);
    return MessagingPage(
      title: 'Messages',
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
        animation: Listenable.merge([store, MentorshipStore.instance]),
        builder: (context, _) {
          final conversations = store.conversationsFor(viewerId);
          final visible = conversations.where((conversation) {
            final peerId = store.peerIdFor(conversation.id, viewerId);
            if (peerId == null) return false;
            final peer = store.contactFor(peerId);
            final matchesFilter = switch (_filter) {
              'Friends' => conversation.isFriendshipConversation,
              'Mentorship' => !conversation.isFriendshipConversation,
              _ => true,
            };
            final query = _searchController.text.trim().toLowerCase();
            return matchesFilter &&
                (query.isEmpty ||
                    peer.name.toLowerCase().contains(query) ||
                    peer.headline.toLowerCase().contains(query));
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search conversations',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 1, 16, 10),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final filter in const ['All', 'Friends', 'Mentorship'])
                      ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.paleBlue,
                        side: BorderSide.none,
                        labelStyle: TextStyle(
                          color: _filter == filter
                              ? AppColors.white
                              : AppColors.deepPrimary,
                          fontSize: 12,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? MessagingEmptyState(
                        title: conversations.isEmpty
                            ? 'No conversations yet'
                            : 'No matching conversations',
                        message: conversations.isEmpty
                            ? 'An active friendship or accepted mentorship is required to message.'
                            : 'Try another search or conversation filter.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 76,
                          color: AppColors.paleBlue,
                        ),
                        itemBuilder: (context, index) => _conversationTile(
                          context,
                          store,
                          visible[index],
                          viewerId,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 7, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.messageFriends,
                      arguments: MessagingRouteArguments(
                        viewerRole: widget.viewerRole,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('New Chat'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _conversationTile(
    BuildContext context,
    MessagingStore store,
    MessagingConversation conversation,
    String viewerId,
  ) {
    final peerId = store.peerIdFor(conversation.id, viewerId);
    if (peerId == null) return const SizedBox.shrink();
    final peer = store.contactFor(peerId);
    final latest = store.latestMessage(conversation.id);
    final preview =
        latest?.content ?? (latest == null ? 'No messages yet' : 'Attachment');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      leading: MessagingAvatar(contact: peer, radius: 25),
      title: Row(
        children: [
          Expanded(
            child: Text(
              peer.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          Text(
            messagingTime(latest?.sentAt ?? conversation.createdAt),
            style: const TextStyle(color: AppColors.mutedText, fontSize: 10),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            conversation.isFriendshipConversation ? 'Friend' : 'Mentorship',
            style: const TextStyle(
              color: AppColors.deepPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.messageChat,
        arguments: MessagingRouteArguments(
          viewerRole: widget.viewerRole,
          conversationId: conversation.id,
        ),
      ),
    );
  }
}
