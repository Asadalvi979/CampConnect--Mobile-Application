import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../data/community_mock_data.dart';
import '../models/comment.dart';
import '../models/community_route_arguments.dart';
import '../services/community_store.dart';
import '../widgets/community_widgets.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({required this.postId, super.key});

  final String postId;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  String? _commentError;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      setState(() => _commentError = 'Write a comment before sending.');
      return;
    }
    setState(() => _commentError = null);
    CommunityStore.instance.addComment(widget.postId, text);
    _commentController.clear();
    FocusScope.of(context).unfocus();
    showCommunityMessage(context, 'Comment added to this preview.');
  }

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    return CommunityScaffold(
      title: 'Comments Screen',
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final post = store.post(widget.postId);
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }
          final comments = store.commentsFor(post.id);
          final author = post.authorId == CommunityMockData.currentUserId
              ? store.currentUserName()
              : CommunityMockData.userName(post.authorId);
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                  children: [
                    CommunityCardSurface(
                      color: AppColors.paleBlue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CommunityAvatar(author, radius: 20),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  author,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              CommunityPill('${comments.length}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, height: 1.4),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pushNamed(
                                AppRoutes.communityPostDetails,
                                arguments: CommunityRouteArguments(
                                  communityId: post.communityId,
                                  postId: post.id,
                                ),
                              ),
                              child: const Text('View full post'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Thread Discussion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        CommunityPill('${comments.length} comments'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (comments.isEmpty)
                      const CommunityCardSurface(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              'No comments yet. Start the discussion.',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                          ),
                        ),
                      )
                    else
                      for (final comment in comments) ...[
                        _CommentCard(comment: comment),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  child: Row(
                    children: [
                      CommunityAvatar(store.currentUserName(), radius: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendComment(),
                          onChanged: (_) {
                            if (_commentError != null) {
                              setState(() => _commentError = null);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            errorText: _commentError,
                            filled: true,
                            fillColor: AppColors.paleBlue,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(26),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      IconButton.filled(
                        tooltip: 'Send comment',
                        onPressed: _sendComment,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    final name = CommunityMockData.userName(comment.authorId);
    return CommunityCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommunityAvatar(name, radius: 19),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      CommunityMockData.userRole(comment.authorId),
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.mutedText),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment.content, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 15,
                color: AppColors.mutedText,
              ),
              SizedBox(width: 5),
              Text(
                'Like',
                style: TextStyle(color: AppColors.mutedText, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
