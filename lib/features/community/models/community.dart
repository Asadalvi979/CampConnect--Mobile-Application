class Community {
  const Community({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.memberCount,
    required this.onlineCount,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final int memberCount;
  final int onlineCount;

  Community copyWith({int? memberCount}) => Community(
    id: id,
    name: name,
    category: category,
    description: description,
    memberCount: memberCount ?? this.memberCount,
    onlineCount: onlineCount,
  );
}
