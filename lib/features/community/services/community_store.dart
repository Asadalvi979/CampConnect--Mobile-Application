import 'package:flutter/foundation.dart';

import '../../../features/profile/models/user_profile.dart';
import '../data/community_mock_data.dart';
import '../models/comment.dart';
import '../models/community.dart';
import '../models/community_membership.dart';
import '../models/post.dart';
import '../models/post_like.dart';

class CommunityStore extends ChangeNotifier {
  CommunityStore._()
    : communities = List.of(CommunityMockData.communities),
      memberships = List.of(CommunityMockData.memberships),
      posts = CommunityMockData.posts,
      likes = [
        for (var index = 0; index < 24; index++)
          PostLike(postId: 'post-workshop', userId: 'seed-$index'),
        for (var index = 0; index < 15; index++)
          PostLike(postId: 'post-campus-iot', userId: 'iot-$index'),
        for (var index = 0; index < 38; index++)
          PostLike(postId: 'post-internships', userId: 'intern-$index'),
      ],
      comments = [
        CommunityComment(
          id: 'comment-zainab',
          postId: 'post-campus-iot',
          authorId: 'zainab',
          content: 'This looks super promising! I can help review the Flutter state management setup if needed.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        CommunityComment(
          id: 'comment-bilal',
          postId: 'post-campus-iot',
          authorId: 'bilal',
          content: 'Great initiative! Make sure to consider message broker failover if campus Wi-Fi drops.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ];

  static final CommunityStore instance = CommunityStore._();

  final List<Community> communities;
  final List<CommunityMembership> memberships;
  final List<CommunityPost> posts;
  final List<PostLike> likes;
  final List<CommunityComment> comments;
  var _nextId = 0;

  String get currentUserId => CommunityMockData.currentUserId;

  Community? community(String id) {
    for (final item in communities) {
      if (item.id == id) return item;
    }
    return null;
  }

  CommunityPost? post(String id) {
    for (final item in posts) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<CommunityPost> postsFor(String communityId) =>
      posts.where((item) => item.communityId == communityId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<CommunityComment> commentsFor(String postId) =>
      comments.where((item) => item.postId == postId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  int likeCount(String postId) =>
      likes.where((like) => like.postId == postId).length;

  bool isLiked(String postId) => likes.any(
    (like) => like.postId == postId && like.userId == currentUserId,
  );

  bool isMember(String communityId) => memberships.any(
    (membership) =>
        membership.communityId == communityId &&
        membership.userId == currentUserId,
  );

  void toggleMembership(String communityId) {
    final existing = memberships.indexWhere(
      (membership) =>
          membership.communityId == communityId &&
          membership.userId == currentUserId,
    );
    if (existing >= 0) {
      memberships.removeAt(existing);
      _updateMemberCount(communityId, -1);
    } else {
      memberships.add(
        CommunityMembership(communityId: communityId, userId: currentUserId),
      );
      _updateMemberCount(communityId, 1);
    }
    notifyListeners();
  }

  void toggleLike(String postId) {
    final existing = likes.indexWhere(
      (like) => like.postId == postId && like.userId == currentUserId,
    );
    if (existing >= 0) {
      likes.removeAt(existing);
    } else {
      likes.add(PostLike(postId: postId, userId: currentUserId));
    }
    notifyListeners();
  }

  CommunityPost addPost(String communityId, String content) {
    final created = CommunityPost(
      id: 'local-post-${_nextId++}',
      communityId: communityId,
      authorId: currentUserId,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    posts.add(created);
    notifyListeners();
    return created;
  }

  void editPost(String postId, String content) {
    final index = posts.indexWhere((item) => item.id == postId);
    if (index < 0 || posts[index].authorId != currentUserId) return;
    posts[index] = posts[index].copyWith(content: content.trim());
    notifyListeners();
  }

  CommunityComment? addComment(String postId, String content) {
    if (post(postId) == null || content.trim().isEmpty) return null;
    final created = CommunityComment(
      id: 'local-comment-${_nextId++}',
      postId: postId,
      authorId: currentUserId,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    comments.add(created);
    notifyListeners();
    return created;
  }

  String currentUserName() => UserProfileStore.instance.profile.value.name;

  void _updateMemberCount(String communityId, int delta) {
    final index = communities.indexWhere((item) => item.id == communityId);
    if (index < 0) return;
    communities[index] = communities[index].copyWith(
      memberCount: communities[index].memberCount + delta,
    );
  }
}
