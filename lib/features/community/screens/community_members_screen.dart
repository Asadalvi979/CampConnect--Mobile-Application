import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/community_mock_data.dart';
import '../services/community_store.dart';
import '../widgets/community_widgets.dart';

class CommunityMembersScreen extends StatefulWidget {
  const CommunityMembersScreen({required this.communityId, super.key});

  final String communityId;

  @override
  State<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  final _searchController = TextEditingController();
  var _role = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final community = CommunityStore.instance.community(widget.communityId);
    if (community == null) {
      return const CommunityScaffold(
        title: 'Community Members',
        body: Center(child: Text('Community not found.')),
      );
    }
    final query = _searchController.text.trim().toLowerCase();
    final members = CommunityMockData.memberPreviews.where((member) {
      final matchesName =
          member.name.toLowerCase().contains(query) ||
          member.detail.toLowerCase().contains(query);
      final matchesRole = _role == 'All' || member.role == _role;
      return matchesName && matchesRole;
    }).toList();

    return CommunityScaffold(
      title: 'Community Members',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.deepPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${community.memberCount} active peers & alumni',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search members by name or semester...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final role in [
                        'All',
                        'Student',
                        'Senior',
                        'Alumni',
                      ]) ...[
                        ChoiceChip(
                          label: Text(switch (role) {
                            'All' => 'All',
                            'Student' => 'Students',
                            'Senior' => 'Seniors',
                            _ => 'Alumni',
                          }),
                          selected: _role == role,
                          onSelected: (_) => setState(() => _role = role),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.lightBlue,
                          labelStyle: TextStyle(
                            color: _role == role
                                ? AppColors.white
                                : AppColors.primaryText,
                            fontSize: 12,
                          ),
                          showCheckmark: false,
                          side: BorderSide.none,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: members.isEmpty
                ? const Center(
                    child: Text(
                      'No members match your search.',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                    itemCount: members.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isCurrentUser =
                          member.name ==
                          CommunityStore.instance.currentUserName();
                      return CommunityCardSurface(
                        color: isCurrentUser
                            ? AppColors.paleBlue
                            : AppColors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CommunityAvatar(member.name, radius: 26),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      CommunityPill(member.role),
                                      const SizedBox(height: 5),
                                      Text(
                                        member.detail,
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentUser)
                                  const CommunityPill('You')
                                else
                                  IconButton(
                                    tooltip: 'Bookmark member',
                                    onPressed: () => showCommunityMessage(
                                      context,
                                      'Member bookmarks are not saved in this preview.',
                                    ),
                                    icon: const Icon(Icons.bookmark_border),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: isCurrentUser
                                    ? () => showCommunityMessage(
                                        context,
                                        'Use My Profile to edit your profile.',
                                      )
                                    : () => showCommunityMessage(
                                        context,
                                        'Public member profiles are available from the profile module.',
                                      ),
                                icon: Icon(
                                  isCurrentUser
                                      ? Icons.edit_outlined
                                      : Icons.chevron_right,
                                  size: 17,
                                ),
                                label: Text(
                                  isCurrentUser
                                      ? 'Edit Profile'
                                      : 'View Profile',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
