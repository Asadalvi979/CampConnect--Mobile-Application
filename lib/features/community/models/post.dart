class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.communityId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String communityId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  CommunityPost copyWith({String? content}) => CommunityPost(
    id: id,
    communityId: communityId,
    authorId: authorId,
    content: content ?? this.content,
    createdAt: createdAt,
  );
}
