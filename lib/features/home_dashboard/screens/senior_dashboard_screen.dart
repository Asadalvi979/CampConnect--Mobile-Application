import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mentorship/widgets/mentorship_widgets.dart';
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
          onTap: () => item.$5 == 'Resources'
              ? openResourceUpload(context, viewerRole: UserProfileRole.senior)
              : item.$5 == 'Projects'
              ? openProjectDiscovery(context, DashboardRole.senior)
              : item.$1 == 'Mentorship Hub'
              ? openMentorshipRequests(context, role: UserProfileRole.senior)
              : openMentorshipDirectory(context, role: UserProfileRole.senior),
        );
      },
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
