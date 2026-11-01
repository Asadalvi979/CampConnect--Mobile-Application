import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../data/community_mock_data.dart';
import '../models/comment.dart';
import '../models/community_route_arguments.dart';
import '../models/post.dart';
import '../services/community_store.dart';
import '../widgets/community_widgets.dart';

class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    return CommunityScaffold(
      title: 'Post Details',
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final post = store.post(postId);
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }
          return _PostDetailsContent(post: post);
        },
      ),
    );
  }
}

class _PostDetailsContent extends StatelessWidget {
  const _PostDetailsContent({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final community = store.community(post.communityId);
    final author = post.authorId == CommunityMockData.currentUserId
        ? store.currentUserName()
        : CommunityMockData.userName(post.authorId);
    final comments = store.commentsFor(post.id);
    final isOwner = post.authorId == CommunityMockData.currentUserId;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Row(
          children: [
            Expanded(child: CommunityPill(community?.name ?? 'Community')),
            if (isOwner)
              IconButton(
                tooltip: 'Edit Post',
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.communityEditPost,
                  arguments: CommunityRouteArguments(
                    communityId: post.communityId,
                    postId: post.id,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
          ],
        ),
        CommunityCardSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CommunityAvatar(author, radius: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${CommunityMockData.userRole(post.authorId)} • ${_postTime(post.createdAt)}',
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.55),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${store.likeCount(post.id)} Likes',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${comments.length} Comments',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => store.toggleLike(post.id),
                      icon: Icon(
                        store.isLiked(post.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: store.isLiked(post.id)
                            ? AppColors.error
                            : AppColors.primaryText,
                      ),
                      label: Text(store.isLiked(post.id) ? 'Liked' : 'Like'),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.communityComments,
                        arguments: CommunityRouteArguments(
                          communityId: post.communityId,
                          postId: post.id,
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Comment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            CommunityPill('${comments.length}'),
          ],
        ),
        const SizedBox(height: 10),
        if (comments.isEmpty)
          CommunityCardSurface(
            child: Column(
              children: [
                const Text(
                  'No comments yet',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.communityComments,
                    arguments: CommunityRouteArguments(
                      communityId: post.communityId,
                      postId: post.id,
                    ),
                  ),
                  child: const Text('Start the discussion'),
                ),
              ],
            ),
          )
        else ...[
          for (final comment in comments.take(3)) ...[
            _CommentPreview(comment: comment),
            const SizedBox(height: 8),
          ],
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.communityComments,
              arguments: CommunityRouteArguments(
                communityId: post.communityId,
                postId: post.id,
              ),
            ),
            child: Text('View all ${comments.length} comments'),
          ),
        ],
      ],
    );
  }
}

class _CommentPreview extends StatelessWidget {
  const _CommentPreview({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    final name = CommunityMockData.userName(comment.authorId);
    return CommunityCardSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityAvatar(name, radius: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(comment.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _postTime(DateTime createdAt) {
  final difference = DateTime.now().difference(createdAt);
  if (difference.inDays > 0) return '${difference.inDays}d ago';
  if (difference.inHours > 0) return '${difference.inHours} hours ago';
  if (difference.inMinutes > 0) return '${difference.inMinutes} minutes ago';
  return 'Just now';
}
