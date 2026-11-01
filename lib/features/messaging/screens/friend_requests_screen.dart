import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/friend_request.dart';
import '../services/messaging_store.dart';
import '../widgets/messaging_widgets.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MessagingStore.instance;
    final viewerId = store.currentUserId(widget.viewerRole);
    return MessagingPage(
      title: 'Friend Requests',
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final incoming = store.receivedRequestsFor(viewerId);
          final outgoing = store.sentRequestsFor(viewerId);
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: AppColors.deepPrimary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Received (${incoming.length})'),
                  Tab(text: 'Sent (${outgoing.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _requestList(incoming, viewerId, received: true),
                    _requestList(outgoing, viewerId, received: false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _requestList(
    List<FriendRequest> requests,
    String viewerId, {
    required bool received,
  }) {
    if (requests.isEmpty) {
      return MessagingEmptyState(
        title: received ? 'No friend requests' : 'No sent requests',
        message: received
            ? 'New requests from other students will appear here.'
            : 'Friend requests you send will appear here.',
        icon: Icons.person_add_alt_1_outlined,
      );
    }
    final store = MessagingStore.instance;
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final request = requests[index];
        final contact = store.contactFor(
          received ? request.senderId : request.receiverId,
        );
        return Card(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              children: [
                Row(
                  children: [
                    MessagingAvatar(contact: contact, radius: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            contact.headline,
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (received) ...[
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _respond(request.id, viewerId, accept: false),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              _respond(request.id, viewerId, accept: true),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ] else
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          color: AppColors.deepPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _respond(String requestId, String viewerId, {required bool accept}) {
    final result = MessagingStore.instance.respondToFriendRequest(
      requestId: requestId,
      viewerId: viewerId,
      accept: accept,
    );
    final message = switch (result) {
      FriendRequestUpdateResult.updated =>
        accept ? 'Friend request accepted.' : 'Friend request declined.',
      FriendRequestUpdateResult.unauthorized =>
        'This request can no longer be updated.',
      FriendRequestUpdateResult.unavailable => 'Friend request unavailable.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
