import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../notifications_announcements/services/notification_announcement_store.dart';
import '../../profile/models/user_profile.dart';
import '../../resources/models/resource_route_arguments.dart';
import '../../resources/services/resource_store.dart';
import '../../navigation/app_routes.dart';
import '../models/admin_user.dart';
import '../services/admin_user_store.dart';
import '../widgets/admin_panel_layout.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => AdminPanelLayout(
    title: 'Admin Dashboard',
    section: AdminPanelSection.dashboard,
    child: AnimatedBuilder(
      animation: AdminUserStore.instance,
      builder: (context, _) => AnimatedBuilder(
        animation: ResourceStore.instance,
        builder: (context, _) => AnimatedBuilder(
          animation: NotificationAnnouncementStore.instance,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1000;
              final store = AdminUserStore.instance;
              final users = store.users;
              final publishedResources = ResourceStore.instance
                  .publishedResources()
                  .length;
              final openReports = ResourceStore.instance.openReports().length;
              final announcements = NotificationAnnouncementStore.instance
                  .publishedAnnouncements()
                  .length;
              final cards = [
                _Metric(
                  title: 'Users',
                  value: '${users.length}',
                  icon: Icons.people_alt_outlined,
                  color: AppColors.primary,
                ),
                _Metric(
                  title: 'Students',
                  value:
                      '${users.where((user) => user.role == UserProfileRole.student).length}',
                  icon: Icons.school_outlined,
                  color: AppColors.primary,
                ),
                _Metric(
                  title: 'Seniors',
                  value:
                      '${users.where((user) => user.role == UserProfileRole.senior).length}',
                  icon: Icons.workspace_premium_outlined,
                  color: AppColors.primary,
                ),
                _Metric(
                  title: 'Alumni',
                  value:
                      '${users.where((user) => user.role == UserProfileRole.alumni).length}',
                  icon: Icons.school_outlined,
                  color: AppColors.primary,
                ),
                _Metric(
                  title: 'Open resource reports',
                  value: '$openReports',
                  subtitle: '$publishedResources published resources',
                  icon: Icons.fact_check_outlined,
                  color: AppColors.primary,
                ),
                _Metric(
                  title: 'Published announcements',
                  value: '$announcements',
                  icon: Icons.campaign_outlined,
                  color: AppColors.primary,
                ),
              ];
              // Card widths are computed from the width left after the
              // scroll view's horizontal padding, so cards never overflow.
              const spacing = AppSpacing.xl;
              final horizontalPadding = wide ? 60.0 : 32.0;
              final availableWidth = constraints.maxWidth - horizontalPadding;
              final cardWidth = wide
                  ? (availableWidth - 2 * spacing) / 3
                  : constraints.maxWidth >= 600
                  ? (availableWidth - spacing) / 2
                  : availableWidth;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 30 : AppSpacing.lg,
                  AppSpacing.xl,
                  wide ? 30 : AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Local preview data—not live university records.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.primaryDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final metric in cards)
                              SizedBox(
                                width: cardWidth,
                                child: _MetricCard(metric: metric),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _QuickActions()),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(
                                child: _ActivityCard(
                                  activities: store.activity,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _QuickActions(),
                          const SizedBox(height: AppSpacing.xxl),
                          _ActivityCard(activities: store.activity),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _Metric {
  const _Metric({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    metric.title,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: metric.color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(metric.icon, color: metric.color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(metric.value, style: textTheme.headlineMedium),
            if (metric.subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(metric.subtitle!, style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Management',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionTile(
            icon: Icons.people_outline,
            title: 'User Management',
            subtitle: 'Search, review, suspend, or reactivate accounts',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminUsers),
          ),
          _ActionTile(
            icon: Icons.fact_check_outlined,
            title: 'Resource Moderation',
            subtitle:
                'Review resource reports in the existing moderation queue',
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.resourceModeration,
              arguments: const ResourceRouteArguments(
                viewerRole: UserProfileRole.admin,
              ),
            ),
          ),
          _ActionTile(
            icon: Icons.campaign_outlined,
            title: 'Announcement Management',
            subtitle: 'Manage published announcements',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.announcements),
          ),
        ],
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: AppColors.paleBlue,
      child: Icon(icon, color: AppColors.primaryDark),
    ),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    onTap: onTap,
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activities});

  final List<AdminActivity> activities;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent administrative activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'No recent activity.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            for (final activity in activities.take(6))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.paleBlue,
                  child: Icon(
                    Icons.history,
                    size: 17,
                    color: AppColors.primaryDark,
                  ),
                ),
                title: Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${activity.context} · ${_formatTime(activity.occurredAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
        ],
      ),
    ),
  );

  String _formatTime(DateTime time) => '${time.month}/${time.day}/${time.year}';
}
