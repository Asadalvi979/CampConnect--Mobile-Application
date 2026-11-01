import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../models/community.dart';
import '../models/community_route_arguments.dart';
import '../services/community_store.dart';
import '../widgets/community_widgets.dart';

class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({super.key});

  @override
  State<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen> {
  final _searchController = TextEditingController();
  var _category = 'All';

  static const _categories = [
    'All',
    'Academic',
    'Technology',
    'Career',
    'Projects',
    'General',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCommunity(String communityId) {
    Navigator.of(context).pushNamed(
      AppRoutes.communityDetails,
      arguments: CommunityRouteArguments(communityId: communityId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    return CommunityScaffold(
      title: 'Community List',
      bottomNavigation: true,
      showBackButton: false,
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final query = _searchController.text.trim().toLowerCase();
          final communities = store.communities.where((community) {
            final matchesQuery =
                query.isEmpty ||
                community.name.toLowerCase().contains(query) ||
                community.category.toLowerCase().contains(query);
            final matchesCategory =
                _category == 'All' ||
                community.category.toLowerCase().contains(
                  _category.toLowerCase(),
                );
            return matchesQuery && matchesCategory;
          }).toList();
          final joined = communities
              .where((community) => store.isMember(community.id))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Communities',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Connect, learn and share with your university community.',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Campus activity',
                    onPressed: () => showCommunityMessage(
                      context,
                      'Community activity notifications are a preview only.',
                    ),
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search communities...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.cancel_outlined),
                        ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = category == _category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = category),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.lightBlue,
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.white
                            : AppColors.primaryText,
                        fontSize: 12,
                      ),
                      showCheckmark: false,
                      side: BorderSide.none,
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Communities',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CommunityPill('${joined.length} Active'),
                ],
              ),
              const SizedBox(height: 10),
              if (joined.isEmpty)
                const CommunityCardSurface(
                  child: Text(
                    'You have not joined a community yet. Explore the directory below.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                )
              else
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: joined.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final community = joined[index];
                      return SizedBox(
                        width: 235,
                        child: CommunityCardSurface(
                          child: InkWell(
                            onTap: () => _openCommunity(community.id),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 64,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    color: AppColors.deepPrimary,
                                    size: 31,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  community.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${community.memberCount} members',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                                const Spacer(),
                                const CommunityPill('✓ Joined'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 22),
              const Text(
                'Explore Communities',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              if (communities.isEmpty)
                const CommunityCardSurface(
                  child: Center(
                    child: Text(
                      'No communities match your search.',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                )
              else
                for (final community in communities) ...[
                  _ExploreCommunityCard(
                    community: community,
                    onOpen: () => _openCommunity(community.id),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
      actions: const [],
    );
  }
}

class _ExploreCommunityCard extends StatelessWidget {
  const _ExploreCommunityCard({required this.community, required this.onOpen});

  final Community community;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    return CommunityCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_outlined,
                    color: AppColors.deepPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 7,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CommunityPill(community.category),
                          Text(
                            '${community.memberCount} members',
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        community.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${community.onlineCount} online',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  store.toggleMembership(community.id);
                  showCommunityMessage(
                    context,
                    store.isMember(community.id)
                        ? 'Joined ${community.name}.'
                        : 'Left ${community.name}.',
                  );
                },
                icon: Icon(
                  store.isMember(community.id) ? Icons.check : Icons.add,
                  size: 16,
                ),
                label: Text(store.isMember(community.id) ? 'Joined' : 'Join'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: store.isMember(community.id)
                      ? AppColors.lightBlue
                      : AppColors.primary,
                  foregroundColor: store.isMember(community.id)
                      ? AppColors.deepPrimary
                      : AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
