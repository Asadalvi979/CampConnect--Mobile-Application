import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/dashboard_mock_data.dart';
import '../models/dashboard_role.dart';
import '../widgets/dashboard_widgets.dart';
import '../../mentorship/widgets/mentorship_widgets.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../notifications_announcements/widgets/notifications_navigation.dart';
import '../../profile/models/user_profile.dart';
import '../../resources/widgets/resource_navigation.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardFrame(
      role: DashboardRole.student,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeCard(context),
          const SizedBox(height: 14),
          _announcement(context),
          const SizedBox(height: 17),
          _services(context),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _quickLink(
                context,
                Icons.explore_outlined,
                'Explore Communities',
                'Communities',
              ),
              _quickLink(context, Icons.search, 'Find Projects', 'Projects'),
              _quickLink(
                context,
                Icons.groups_2_outlined,
                'Find Mentors',
                'Mentorship',
              ),
            ],
          ),
          const SizedBox(height: 17),
          DashboardSectionTitle(
            'Available Mentors',
            trailing: 'See All',
            onTap: () =>
                openMentorshipDirectory(context, role: UserProfileRole.student),
          ),
          _mentors(context),
          const SizedBox(height: 16),
          DashboardSectionTitle(
            'Project Opportunities',
            trailing: 'Explore',
            onTap: () => openProjectDiscovery(context, DashboardRole.student),
          ),
          for (final project in DashboardMockData.studentProjects) ...[
            _projectCard(context, project),
            const SizedBox(height: 9),
          ],
          DashboardSectionTitle(
            'Community Discussions',
            trailing: 'Feed',
            onTap: () => openCommunityList(context),
          ),
          _discussionCard(context),
          const SizedBox(height: 16),
          DashboardSectionTitle(
            'Verified Resources',
            trailing: 'All Files',
            onTap: () => openResourceLibrary(
              context,
              viewerRole: UserProfileRole.student,
            ),
          ),
          _resourceCard(context),
          const SizedBox(height: 14),
          _reminderCard(),
        ],
      ),
    );
  }

  Widget _welcomeCard(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const DashboardAvatar('UA', radius: 25),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Usman!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      DashboardMockData.studentProgram,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      DashboardMockData.campus,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.deepPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Student ID Card',
                onPressed: () =>
                    showDashboardPreviewMessage(context, 'Student ID card'),
                icon: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.deepPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: AppColors.deepPrimary,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    DashboardMockData.semester,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                const Text(
                  DashboardMockData.semesterWeek,
                  style: TextStyle(fontSize: 9),
                ),
                const SizedBox(width: 7),
                SizedBox(
                  width: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.5,
                      minHeight: 5,
                      backgroundColor: AppColors.lightBlue,
                      color: AppColors.primary,
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

  Widget _announcement(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.deepPrimary],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPrimary.withValues(alpha: 0.15),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DashboardPill(
                '📌  PINNED ANNOUNCEMENT',
                color: Color(0x33FFFFFF),
              ),
              const Spacer(),
              Text(
                'Oct 20, 2024',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            DashboardMockData.studentAnnouncementTitle,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            DashboardMockData.studentAnnouncement,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                size: 14,
                color: AppColors.white,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Faculty of Computing',
                  style: TextStyle(color: AppColors.white, fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: () => openAnnouncements(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.deepPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  minimumSize: const Size(0, 34),
                ),
                child: const Text(
                  'View Notice  →',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _services(BuildContext context) {
    final services = [
      (
        title: 'Communities',
        subtitle: 'Find your people',
        icon: Icons.groups_rounded,
        accent: const Color(0xFFE7EEFF),
        onTap: () => openCommunityList(context),
      ),
      (
        title: 'Projects',
        subtitle: 'Build together',
        icon: Icons.rocket_launch_outlined,
        accent: const Color(0xFFE9E6FF),
        onTap: () => openProjectDiscovery(context, DashboardRole.student),
      ),
      (
        title: 'Messages',
        subtitle: 'Chat with peers',
        icon: Icons.forum_outlined,
        accent: const Color(0xFFE1F4F4),
        onTap: () =>
            openMessageInbox(context, viewerRole: UserProfileRole.student),
      ),
      (
        title: 'Resources',
        subtitle: 'Notes & past papers',
        icon: Icons.menu_book_outlined,
        accent: const Color(0xFFE5F5EA),
        onTap: () =>
            openResourceLibrary(context, viewerRole: UserProfileRole.student),
      ),
      (
        title: 'Mentorship',
        subtitle: 'Learn from seniors',
        icon: Icons.people_alt_outlined,
        accent: const Color(0xFFFFF0DF),
        onTap: () =>
            openMentorshipDirectory(context, role: UserProfileRole.student),
      ),
      (
        title: 'Announcements',
        subtitle: 'Campus updates',
        icon: Icons.campaign_outlined,
        accent: const Color(0xFFFFE9ED),
        onTap: () => openAnnouncements(context),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBlue),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: .035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.deepPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus Services',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Everything you need, all in one place',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '6 services',
                  style: TextStyle(
                    color: AppColors.deepPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 9.0;
              final itemWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final service in services)
                    SizedBox(
                      width: itemWidth,
                      child: _campusServiceTile(
                        title: service.title,
                        subtitle: service.subtitle,
                        icon: service.icon,
                        accent: service.accent,
                        onTap: service.onTap,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _campusServiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 75),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.lightBlue),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.deepPrimary, size: 20),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.mutedText,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickLink(
    BuildContext context,
    IconData icon,
    String label,
    String module,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 15, color: AppColors.deepPrimary),
      label: Text(label, style: const TextStyle(fontSize: 10)),
      backgroundColor: AppColors.lightBlue,
      side: BorderSide.none,
      onPressed: () => module == 'Communities'
          ? openCommunityList(context)
          : module == 'Projects'
          ? openProjectDiscovery(context, DashboardRole.student)
          : module == 'Mentorship'
          ? openMentorshipDirectory(context, role: UserProfileRole.student)
          : module == 'Messages'
          ? openMessageInbox(context, viewerRole: UserProfileRole.student)
          : module == 'Resources'
          ? openResourceLibrary(context, viewerRole: UserProfileRole.student)
          : module == 'Announcements'
          ? openAnnouncements(context)
          : showDashboardPreviewMessage(context, module),
    );
  }

  Widget _mentors(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DashboardMockData.mentors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final mentor = DashboardMockData.mentors[index];
          return SizedBox(
            width: 220,
            child: DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DashboardAvatar(mentor.initials, radius: 17),
                      const SizedBox(width: 7),
                      const DashboardPill('Alumni Mentor'),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    mentor.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    mentor.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    mentor.skills,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.deepPrimary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 29,
                    child: FilledButton(
                      onPressed: () => openMentorshipDirectory(
                        context,
                        role: UserProfileRole.student,
                      ),
                      child: const Text(
                        'Browse Mentors',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _projectCard(BuildContext context, DashboardProject project) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DashboardPill(project.meta)),
              const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.deepPrimary,
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            project.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            project.tags,
            style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  openProjectDiscovery(context, DashboardRole.student),
              child: const Text('View Project', style: TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _discussionCard(BuildContext context) {
    final post = DashboardMockData.studentPost;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DashboardPill(post.community),
              const SizedBox(width: 6),
              const Text(
                '• 2h ago',
                style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border, size: 18),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            post.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const DashboardAvatar('HT', radius: 10),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Posted by ${post.author}',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
              Text(post.replies, style: const TextStyle(fontSize: 9)),
            ],
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => openCommunityList(context),
              child: const Text(
                'View Discussion',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resourceCard(BuildContext context) {
    final resource = DashboardMockData.studentResource;
    return DashboardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardPill('PDF • 2.8 MB'),
                const SizedBox(height: 4),
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  resource.description,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resource.meta,
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                    TextButton(
                      onPressed: () => openResourceDetails(
                        context,
                        resourceId: 'resource-database-papers',
                        viewerRole: UserProfileRole.student,
                      ),
                      child: const Text(
                        'View Resource',
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

  Widget _reminderCard() {
    return DashboardCard(
      color: AppColors.paleBlue,
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.deepPrimary),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Reminder',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                ),
                SizedBox(height: 2),
                Text(
                  DashboardMockData.studentReminder,
                  style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
