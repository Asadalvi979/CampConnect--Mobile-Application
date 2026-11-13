import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
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
          _welcome(context),
          const SizedBox(height: AppSpacing.xxl),
          _announcement(context),
          const SizedBox(height: AppSpacing.xxl),
          _services(context),
          const SizedBox(height: AppSpacing.xxl),
          _reminderCard(context),
        ],
      ),
    );
  }

  // Flat greeting: no card behind it, avatar + text directly on the
  // background. The semester strip is a simple row with a thin progress
  // line — no nested card.
  Widget _welcome(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            const DashboardAvatar('UA', radius: 25),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Usman!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DashboardMockData.studentProgram,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DashboardMockData.campus,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
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
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                DashboardMockData.semester,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              DashboardMockData.semesterWeek,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: const LinearProgressIndicator(value: 0.5, minHeight: 4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // White card with a blue left accent bar — the solid blue box is gone.
  // Dark text throughout, and the body shows in full (no 2-line ellipsis).
  // NOTE: the accent bar is a Positioned strip in a Stack, not a Border
  // side (Border + borderRadius throws at paint time unless all sides are
  // uniform) and not a stretched Row (the dashboard scrolls vertically,
  // so a Row's cross-axis stretch gets infinite height).
  Widget _announcement(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg - 1),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md + 4,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: DashboardPill(
                          'PINNED ANNOUNCEMENT',
                          icon: Icons.push_pin,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Oct 20, 2024',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    DashboardMockData.studentAnnouncementTitle,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DashboardMockData.studentAnnouncement,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Faculty of Computing',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => openAnnouncements(context),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          minimumSize: const Size(0, AppTargets.min),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Notice',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _services(BuildContext context) {
    // One blue tint for every tile icon — no per-service accent colors.
    final services = [
      (
        title: 'Communities',
        subtitle: 'Find your people',
        icon: Icons.groups_rounded,
        onTap: () => openCommunityList(context),
      ),
      (
        title: 'Projects',
        subtitle: 'Build together',
        icon: Icons.rocket_launch_outlined,
        onTap: () => openProjectDiscovery(context, DashboardRole.student),
      ),
      (
        title: 'Messages',
        subtitle: 'Chat with peers',
        icon: Icons.forum_outlined,
        onTap: () =>
            openMessageInbox(context, viewerRole: UserProfileRole.student),
      ),
      (
        title: 'Resources',
        subtitle: 'Notes & past papers',
        icon: Icons.menu_book_outlined,
        onTap: () =>
            openResourceLibrary(context, viewerRole: UserProfileRole.student),
      ),
      (
        title: 'Mentorship',
        subtitle: 'Learn from seniors',
        icon: Icons.people_alt_outlined,
        onTap: () =>
            openMentorshipDirectory(context, role: UserProfileRole.student),
      ),
      (
        title: 'Announcements',
        subtitle: 'Campus updates',
        icon: Icons.campaign_outlined,
        onTap: () => openAnnouncements(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Campus Services', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = AppSpacing.md;
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
                      onTap: service.onTap,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _campusServiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          // Vertical layout: the icon row sits above the text, so the
          // title gets the tile's full width. In the old horizontal row
          // the ~97px text column truncated 'Announcements' to
          // 'Announceme…' at the 12px floor.
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.tileBlue,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, color: AppColors.tileBlueIcon, size: 20),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textMuted,
                    size: 12,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reminderCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DashboardCard(
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Reminder',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DashboardMockData.studentReminder,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
