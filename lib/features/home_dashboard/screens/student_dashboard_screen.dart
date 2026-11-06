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
                  ],
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
