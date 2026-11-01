import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
                  title: 'Mock users',
                  value: '${users.length}',
                  subtitle: 'Local preview accounts',
                  icon: Icons.people_alt_outlined,
                  color: AppColors.primary,
                ),
                _Metric(
                  title: 'Students',
                  value:
                      '${users.where((user) => user.role == UserProfileRole.student).length}',
                  subtitle: 'In this mock directory',
                  icon: Icons.school_outlined,
                  color: const Color(0xFF2563EB),
                ),
                _Metric(
                  title: 'Seniors',
                  value:
                      '${users.where((user) => user.role == UserProfileRole.senior).length}',
                  subtitle: 'In this mock directory',
                  icon: Icons.workspace_premium_outlined,
                  color: const Color(0xFF7C3AED),
                ),
                _Metric(
                  title: 'Alumni',
                  value:
                      '${users.where((user) => user.role == UserProfileRole.alumni).length}',
                  subtitle: 'In this mock directory',
                  icon: Icons.school_outlined,
                  color: const Color(0xFF0891B2),
                ),
                _Metric(
                  title: 'Open resource reports',
                  value: '$openReports',
                  subtitle: '$publishedResources published resources',
                  icon: Icons.fact_check_outlined,
                  color: const Color(0xFFF59E0B),
                ),
                _Metric(
                  title: 'Published announcements',
                  value: '$announcements',
                  subtitle: 'Local announcement store',
                  icon: Icons.campaign_outlined,
                  color: const Color(0xFF059669),
                ),
              ];
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 30 : 16,
                  20,
                  wide ? 30 : 16,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Administrative tools and local preview data.',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 17),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.deepPrimary,
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'All figures and actions are local mock previews, not live university data.',
                                  style: TextStyle(
                                    color: AppColors.deepPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            for (final metric in cards)
                              SizedBox(
                                width: wide
                                    ? (constraints.maxWidth - 56) / 3
                                    : constraints.maxWidth >= 600
                                    ? (constraints.maxWidth - 14) / 2
                                    : constraints.maxWidth,
                                child: _MetricCard(metric: metric),
                              ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _QuickActions()),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _ActivityCard(
                                  activities: store.activity,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _QuickActions(),
                          const SizedBox(height: 16),
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
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: AppColors.white,
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(metric.icon, color: metric.color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            metric.value,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            metric.subtitle,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: AppColors.white,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Management',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
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
      child: Icon(icon, color: AppColors.deepPrimary),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    onTap: onTap,
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activities});

  final List<AdminActivity> activities;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: AppColors.white,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent administrative activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mock entries and changes made in this session',
            style: TextStyle(color: AppColors.mutedText, fontSize: 11),
          ),
          const SizedBox(height: 10),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No activity in this preview yet.',
                style: TextStyle(color: AppColors.mutedText),
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
                    color: AppColors.deepPrimary,
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
                    fontSize: 10,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
        ],
      ),
    ),
  );

  String _formatTime(DateTime time) => '${time.month}/${time.day}/${time.year}';
}
