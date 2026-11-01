import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mentorship/widgets/mentorship_widgets.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../notifications_announcements/widgets/notifications_navigation.dart';
import '../../profile/models/user_profile.dart';
import '../../resources/widgets/resource_navigation.dart';
import '../data/dashboard_mock_data.dart';
import '../models/dashboard_role.dart';
import '../widgets/dashboard_widgets.dart';

class SeniorDashboardScreen extends StatelessWidget {
  const SeniorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardFrame(
      role: DashboardRole.senior,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeCard(),
          const SizedBox(height: 17),
          DashboardSectionTitle(
            'Senior Actions',
            trailing: DashboardMockData.seniorActions,
          ),
          _seniorActions(context),
          const SizedBox(height: 15),
          _mentorshipPrompt(context),
          const SizedBox(height: 16),
          DashboardSectionTitle(
            'CampConnect Modules',
            trailing: 'All Tools',
            onTap: () => showDashboardPreviewMessage(context, 'Modules'),
          ),
          _modules(context),
          const SizedBox(height: 15),
          DashboardCard(
            child: Column(
              children: [
                DashboardSectionTitle(
                  'Capstone Opportunities',
                  trailing: 'View All',
                  onTap: () =>
                      openProjectDiscovery(context, DashboardRole.senior),
                ),
                for (final project in DashboardMockData.seniorProjects)
                  _opportunity(context, project),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _discussion(context),
          const SizedBox(height: 15),
          _resourceHub(context),
          const SizedBox(height: 15),
          _notice(context),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return DashboardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardAvatar('ZF', radius: 25),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Zainab!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 3),
                Text(
                  DashboardMockData.seniorProgram,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    DashboardPill('Riphah Sahiwal Campus'),
                    DashboardPill('Lead Mentor', color: AppColors.paleBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seniorActions(BuildContext context) {
    const actions = [
      (
        'Guide Juniors',
        'Office hours open',
        Icons.people_alt_outlined,
        AppColors.lightBlue,
        'Mentorship',
      ),
      (
        'Explore Projects',
        'FYP & Capstone',
        Icons.explore_outlined,
        AppColors.paleBlue,
        'Projects',
      ),
      (
        'Mentorship Hub',
        '2 Pending review',
        Icons.assignment_turned_in_outlined,
        Color(0xFFB7F7DA),
        'Mentorship',
      ),
      (
        'Share Resources',
        'BSSE Syllabus notes',
        Icons.upload_file_outlined,
        AppColors.lightBlue,
        'Resources',
      ),
    ];
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 2.45,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return DashboardShortcut(
          title: item.$1,
          subtitle: item.$2,
          icon: item.$3,
          accent: item.$4,
          onTap: () => item.$5 != 'Mentorship'
              ? showDashboardPreviewMessage(context, item.$5)
              : item.$1 == 'Mentorship Hub'
              ? openMentorshipRequests(context, role: UserProfileRole.senior)
              : openMentorshipDirectory(context, role: UserProfileRole.senior),
        );
      },
    );
  }

  Widget _mentorshipPrompt(BuildContext context) => DashboardCard(
    child: Row(
      children: [
        const Icon(
          Icons.handshake_outlined,
          color: AppColors.deepPrimary,
          size: 25,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find an Alumni Mentor',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 3),
              Text(
                'Explore alumni who can guide your academic and career goals.',
                style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () =>
              openMentorshipDirectory(context, role: UserProfileRole.senior),
          child: const Text('Explore'),
        ),
      ],
    ),
  );

  Widget _modules(BuildContext context) {
    const items = [
      ('Communities', '8 Active', Icons.groups_outlined, 'Community'),
      ('Projects', '3 Joined', Icons.folder_open_outlined, 'Projects'),
      ('Messages', '5 Unread', Icons.forum_outlined, 'Messages'),
      ('Resources', '142 Files', Icons.menu_book_outlined, 'Resources'),
      ('Mentorship', '2 Alerts', Icons.handshake_outlined, 'Mentorship'),
      ('Notices', 'Official', Icons.campaign_outlined, 'Announcements'),
    ];
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardShortcut(
          title: item.$1,
          subtitle: item.$2,
          icon: item.$3,
          compact: true,
          onTap: () => item.$4 == 'Community'
              ? openCommunityList(context)
              : item.$4 == 'Mentorship'
              ? openMentorshipRequests(context, role: UserProfileRole.senior)
              : item.$4 == 'Projects'
              ? openProjectDiscovery(context, DashboardRole.senior)
              : item.$4 == 'Messages'
              ? openMessageInbox(context, viewerRole: UserProfileRole.senior)
              : item.$4 == 'Resources'
              ? openResourceLibrary(context, viewerRole: UserProfileRole.senior)
              : item.$4 == 'Announcements'
              ? openAnnouncements(context)
              : showDashboardPreviewMessage(context, item.$4),
        );
      },
    );
  }

  Widget _opportunity(BuildContext context, DashboardProject project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.rocket_launch_outlined,
            color: AppColors.deepPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardPill(project.tags),
                const SizedBox(height: 4),
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  project.description,
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
          const SizedBox(width: 6),
          TextButton(
            onPressed: () =>
                openProjectDiscovery(context, DashboardRole.senior),
            child: const Text('View Project', style: TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  Widget _discussion(BuildContext context) {
    final post = DashboardMockData.seniorDiscussion;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Discussions to Guide',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => openCommunityList(context),
                child: const Text(
                  'Mobile Dev Club',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
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
                    const DashboardAvatar('UA', radius: 11),
                    const SizedBox(width: 5),
                    Text(
                      '${post.author} asked  •  1h ago',
                      style: const TextStyle(fontSize: 9),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '“${post.title}”',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'We are building an IoT telematics mobile app and unsure which state management approach to use.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.replies,
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                    TextButton(
                      onPressed: () => openCommunityList(context),
                      child: const Text(
                        'Answer Question',
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

  Widget _resourceHub(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Resource Sharing Hub',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.verified_outlined, color: AppColors.success, size: 16),
              SizedBox(width: 4),
              Text(
                'Verified Contributor',
                style: TextStyle(fontSize: 9, color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _resourceAction(
                  context,
                  icon: Icons.cloud_upload_outlined,
                  title: 'Upload Study Notes',
                  detail: 'PDF, Slide decks or GitHub zip files.',
                  button: '+ Add Material',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _resourceAction(
                  context,
                  icon: Icons.folder_open_outlined,
                  title: 'My Uploaded Notes',
                  detail: '4 Live resources with 380+ junior downloads.',
                  button: 'Manage 4 Files',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resourceAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String detail,
    required String button,
  }) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.deepPrimary, size: 20),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => button == '+ Add Material'
                  ? openResourceUpload(
                      context,
                      viewerRole: UserProfileRole.senior,
                    )
                  : openMyResources(
                      context,
                      viewerRole: UserProfileRole.senior,
                    ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 30),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(button, style: const TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice(BuildContext context) {
    final notice = DashboardMockData.seniorNotice;
    return DashboardCard(
      child: Row(
        children: [
          const Icon(Icons.campaign_outlined, color: AppColors.error, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.meta,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  notice.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  notice.description,
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
            onPressed: () => openAnnouncements(context),
            child: const Text('View Notice', style: TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }
}
