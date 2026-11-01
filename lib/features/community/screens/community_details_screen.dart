import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../models/community.dart';
import '../models/community_route_arguments.dart';
import '../services/community_store.dart';
import '../widgets/community_widgets.dart';

class CommunityDetailsScreen extends StatelessWidget {
  const CommunityDetailsScreen({required this.communityId, super.key});

  final String communityId;

  void _createPost(BuildContext context) {
    Navigator.of(context).pushNamed<void>(
      AppRoutes.communityCreatePost,
      arguments: CommunityRouteArguments(communityId: communityId),
    );
  }

  void _openPost(BuildContext context, String postId) {
    Navigator.of(context).pushNamed(
      AppRoutes.communityPostDetails,
      arguments: CommunityRouteArguments(
        communityId: communityId,
        postId: postId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    return CommunityScaffold(
      title: 'Community Details',
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final community = store.community(communityId);
          if (community == null) {
            return const Center(child: Text('Community not found.'));
          }
          return _CommunityDetailsContent(
            community: community,
            isJoined: store.isMember(communityId),
            onJoin: () => store.toggleMembership(communityId),
            onCreatePost: () => _createPost(context),
            onOpenMembers: () => Navigator.of(context).pushNamed(
              AppRoutes.communityMembers,
              arguments: CommunityRouteArguments(communityId: communityId),
            ),
            onOpenPost: (id) => _openPost(context, id),
          );
        },
      ),
    );
  }
}

class _CommunityDetailsContent extends StatelessWidget {
  const _CommunityDetailsContent({
    required this.community,
    required this.isJoined,
    required this.onJoin,
    required this.onCreatePost,
    required this.onOpenMembers,
    required this.onOpenPost,
  });

  final Community community;
  final bool isJoined;
  final VoidCallback onJoin;
  final VoidCallback onCreatePost;
  final VoidCallback onOpenMembers;
  final ValueChanged<String> onOpenPost;

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final posts = store.postsFor(community.id);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          height: 155,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.deepPrimary, AppColors.primary],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.groups_rounded, color: AppColors.white, size: 62),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      community.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onJoin,
                    child: Text(isJoined ? '✓ Joined' : '+ Join'),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 6,
                children: [
                  CommunityPill(community.category),
                  const CommunityPill('Riphah Sahiwal Campus'),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Icon(Icons.groups_outlined, size: 17),
                  Text('${community.memberCount} Members'),
                  const Icon(Icons.circle, color: AppColors.success, size: 9),
                  Text('${community.onlineCount} Online now'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                community.description,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: onOpenMembers,
                      icon: const Icon(Icons.groups_outlined, size: 18),
                      label: Text('Members (${community.memberCount})'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Invite',
                    onPressed: () => showCommunityMessage(
                      context,
                      'Inviting members is not available in this local preview.',
                    ),
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CommunityCardSurface(
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        CommunityAvatar('Asadullah Sadiq', radius: 19),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Write something to the community...',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 17,
                          color: AppColors.deepPrimary,
                        ),
                        const SizedBox(width: 5),
                        const Text('Photo', style: TextStyle(fontSize: 11)),
                        const Spacer(),
                        FilledButton(
                          onPressed: onCreatePost,
                          child: const Text('Create Post'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (posts.isEmpty)
                CommunityCardSurface(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.forum_outlined,
                        color: AppColors.deepPrimary,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No discussions yet',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Start a conversation with your community.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: onCreatePost,
                        child: const Text('Create a post'),
                      ),
                    ],
                  ),
                )
              else
                for (final post in posts) ...[
                  CommunityPostCard(
                    post: post,
                    onOpen: () => onOpenPost(post.id),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
