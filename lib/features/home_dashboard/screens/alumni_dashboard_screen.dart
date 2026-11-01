import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mentorship/widgets/mentorship_widgets.dart';
import '../../notifications_announcements/widgets/notifications_navigation.dart';
import '../../profile/models/user_profile.dart';
import '../../resources/widgets/resource_navigation.dart';
import '../data/dashboard_mock_data.dart';
import '../models/dashboard_role.dart';
import '../widgets/dashboard_widgets.dart';

class AlumniDashboardScreen extends StatelessWidget {
  const AlumniDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardFrame(
      role: DashboardRole.alumni,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeCard(context),
          const SizedBox(height: 15),
          DashboardSectionTitle('Quick Navigation', trailing: 'Alumni Console'),
          _quickNavigation(context),
          const SizedBox(height: 15),
          _requests(context),
          const SizedBox(height: 15),
          _activeMentorships(context),
          const SizedBox(height: 15),
          _industryAdvisory(context),
          const SizedBox(height: 15),
          _careerDiscussion(context),
          const SizedBox(height: 15),
          _knowledgeSharing(context),
          const SizedBox(height: 15),
          _campusNotice(context),
          const SizedBox(height: 14),
          Center(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.secondaryText,
                ),
                children: [
                  const TextSpan(
                    text: 'Need assistance with your alumni verification? ',
                  ),
                  WidgetSpan(
                    child: InkWell(
                      onTap: () => showDashboardPreviewMessage(
                        context,
                        'Alumni support',
                      ),
                      child: const Text(
                        'Contact Campus Alumni Office',
                        style: TextStyle(color: AppColors.deepPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardAvatar('BA', radius: 25),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Welcome back, Bilal!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        DashboardPill('Class of ’21'),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      DashboardMockData.alumniTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 3,
                      children: [
                        DashboardPill(
                          'Mentoring Active',
                          color: Color(0xFFB7F7DA),
                        ),
                        DashboardPill(
                          'Sahiwal Campus Chapter',
                          color: AppColors.paleBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Share profile',
                onPressed: () =>
                    showDashboardPreviewMessage(context, 'Profile sharing'),
                icon: const Icon(Icons.share_outlined, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_outlined,
                  color: AppColors.deepPrimary,
                  size: 19,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Official alumni mentorships run under institutional oversight. Direct student messaging activates once a request is formally accepted.',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickNavigation(BuildContext context) {
    const items = [
      (
        'Requests',
        'Review candidate profiles',
        Icons.pending_actions_outlined,
        'Mentorship',
      ),
      (
        'Communities',
        'Department & batch hubs',
        Icons.groups_outlined,
        'Community',
      ),
      (
        'Projects',
        'FYPs & tech prototypes',
        Icons.rocket_launch_outlined,
        'Projects',
      ),
      (
        'Resources',
        'Guides, roadmaps, kits',
        Icons.cloud_upload_outlined,
        'Resources',
      ),
    ];
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardShortcut(
          title: item.$1,
          subtitle: item.$2,
          icon: item.$3,
          onTap: () => item.$4 == 'Mentorship'
              ? openMentorshipRequests(
                  context,
                  role: UserProfileRole.alumni,
                  initialTab: 1,
                )
              : item.$4 == 'Community'
              ? openCommunityList(context)
              : item.$4 == 'Projects'
              ? openProjectDiscovery(context, DashboardRole.alumni)
              : item.$4 == 'Resources'
              ? openResourceLibrary(context, viewerRole: UserProfileRole.alumni)
              : item.$4 == 'Announcements'
              ? openAnnouncements(context)
              : showDashboardPreviewMessage(context, item.$4),
        );
      },
    );
  }

  Widget _requests(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mentorship Requests',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const DashboardPill('3 Pending', color: Color(0xFFFFE4E4)),
              TextButton(
                onPressed: () => openMentorshipRequests(
                  context,
                  role: UserProfileRole.alumni,
                  initialTab: 1,
                ),
                child: const Text('View All', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
          for (final request in DashboardMockData.alumniMentorshipRequests) ...[
            _mentorshipRequest(context, request),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _mentorshipRequest(BuildContext context, DashboardRequest request) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              DashboardAvatar(
                request.name == 'Asadullah Sadiq' ? 'AS' : 'HN',
                radius: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      request.study,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              DashboardPill(request.when, color: AppColors.white),
            ],
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '“${request.message}”',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Verified Student',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => openMentorshipRequests(
                  context,
                  role: UserProfileRole.alumni,
                  initialTab: 1,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 31),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text(
                  'Review request',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeMentorships(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active Mentorships',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const DashboardPill('2 Students'),
              TextButton(
                onPressed: () => openActiveMentorships(
                  context,
                  role: UserProfileRole.alumni,
                ),
                child: const Text('View All', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _menteeProgress(
            context,
            'AS',
            'Asadullah Sadiq',
            'BSSE • Career Path...',
            'Next sync: Tomorrow 4:00 PM',
            'Chat Enabled',
          ),
          const SizedBox(height: 7),
          _menteeProgress(
            context,
            'HT',
            'Hamza Tariq',
            'BSCS • System Archi...',
            'Monthly Milestone Goal',
            '2 of 3 met (66%)',
          ),
        ],
      ),
    );
  }

  Widget _menteeProgress(
    BuildContext context,
    String initials,
    String name,
    String subtitle,
    String footnote,
    String progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Row(
            children: [
              DashboardAvatar(initials, radius: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => openActiveMentorships(
                  context,
                  role: UserProfileRole.alumni,
                ),
                child: const Text(
                  'View details',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  footnote,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const Icon(
                Icons.chat_bubble_outline,
                size: 12,
                color: AppColors.success,
              ),
              const SizedBox(width: 3),
              Text(
                progress,
                style: const TextStyle(fontSize: 8, color: AppColors.success),
              ),
            ],
          ),
          if (progress.contains('%'))
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: LinearProgressIndicator(
                value: 0.66,
                minHeight: 4,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _industryAdvisory(BuildContext context) {
    final project = DashboardMockData.alumniProjects.first;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Industry Advisory Board',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const Text(
                'FYP 2025',
                style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: DashboardPill('Advisory Request')),
                    IconButton(
                      onPressed: () =>
                          openProjectDiscovery(context, DashboardRole.alumni),
                      icon: const Icon(
                        Icons.smart_toy_outlined,
                        size: 19,
                        color: AppColors.deepPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  project.description,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Students require an external industry mentor to critique their LLM orchestration architecture, evaluation metrics, and API cost containment strategies.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '◷ Est. 1 hr/bi-weekly',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () =>
                          openProjectDiscovery(context, DashboardRole.alumni),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 31),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Review Project',
                        style: TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _careerDiscussion(BuildContext context) {
    final post = DashboardMockData.alumniPost;
    return DashboardCard(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Career Discussions',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => openCommunityList(context),
                child: const Text(
                  'Explore Forum',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DashboardPill(post.community),
                    const Spacer(),
                    const Text(
                      '3h ago',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Key pitfalls junior graduates face during tech-stack selections, hiring interviews at Lahore/Islamabad tech hubs...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '▣ ${post.replies}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              '44 likes',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => openCommunityList(context),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Join Discussion',
                        style: TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _knowledgeSharing(BuildContext context) {
    final resource = DashboardMockData.alumniResource;
    return DashboardCard(
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Knowledge Sharing',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'Contribution Hub',
                style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.library_books_outlined,
                color: AppColors.deepPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      resource.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => openResourceUpload(
                  context,
                  viewerRole: UserProfileRole.alumni,
                ),
                child: const Text('Upload', style: TextStyle(fontSize: 9)),
              ),
            ],
          ),
          const Divider(height: 15),
          Row(
            children: [
              const Icon(Icons.terminal, color: AppColors.success),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Published Cloud Cheatsheet',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '86 downloads  •  Updated Nov 2024',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => openResourceLibrary(
                  context,
                  viewerRole: UserProfileRole.alumni,
                ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campusNotice(BuildContext context) {
    final notice = DashboardMockData.alumniNotice;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Campus Administration Notice',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const Text(
                'Riphah Sahiwal',
                style: TextStyle(fontSize: 8, color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DashboardPill('Campus Notice'),
          const SizedBox(height: 5),
          Text(
            notice.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            notice.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Alumni Registration Quota',
                  style: TextStyle(fontSize: 9),
                ),
              ),
              const Text(
                '71% Enrolled (142 / 200)',
                style: TextStyle(fontSize: 8, color: AppColors.deepPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const LinearProgressIndicator(
            value: 0.71,
            minHeight: 4,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Closes in 5 days',
                  style: TextStyle(fontSize: 8, color: AppColors.secondaryText),
                ),
              ),
              TextButton(
                onPressed: () => openAnnouncements(context),
                child: const Text('View Notice', style: TextStyle(fontSize: 9)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
