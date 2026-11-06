import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../admin_panel/widgets/admin_panel_layout.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/announcement.dart';
import '../services/notification_announcement_store.dart';
import '../widgets/notifications_navigation.dart';

class AnnouncementListScreen extends StatelessWidget {
  const AnnouncementListScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  Widget build(BuildContext context) {
    final store = NotificationAnnouncementStore.instance;
    final isAdmin = viewerRole == UserProfileRole.admin;
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Announcement Management' : 'Announcements'),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Create announcement',
              onPressed: () => _createAnnouncement(context),
              icon: const Icon(Icons.add_circle_outline),
            ),
        ],
      ),
      bottomNavigationBar: isAdmin
          ? const AdminPanelBottomNavigation(
              selected: AdminPanelSection.announcements,
            )
          : null,
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final announcements = store.publishedAnnouncements();
            if (announcements.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        color: AppColors.deepPrimary,
                        size: 46,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No announcements available',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                for (final announcement in announcements) ...[
                  _announcementCard(context, announcement),
                  const SizedBox(height: 10),
                ],
                if (isAdmin)
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => _createAnnouncement(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Announcement'),
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Local preview; publishing does not send notifications.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 10),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _announcementCard(
    BuildContext context,
    CampusAnnouncement announcement,
  ) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => openAnnouncementDetails(
          context,
          announcementId: announcement.announcementId,
        ),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      announcement.status.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.deepPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.campaign_outlined,
                    color: AppColors.deepPrimary,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                announcement.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Administrator · ${_formatDate(announcement.publishedAt)}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAnnouncement(BuildContext context) async {
    final result = await Navigator.of(context)
        .pushNamed(AppRoutes.announcementCreate);
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Announcement published.')),
        );
    }
  }

  String _formatDate(DateTime date) =>
      '${_month(date.month)} ${date.day}, ${date.year}';

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}
