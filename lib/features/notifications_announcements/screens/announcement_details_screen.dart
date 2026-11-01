import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../admin_panel/widgets/admin_panel_layout.dart';
import '../../profile/models/user_profile.dart';
import '../models/announcement.dart';
import '../services/notification_announcement_store.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({required this.announcementId, super.key});

  final int announcementId;

  @override
  Widget build(BuildContext context) {
    final announcement = NotificationAnnouncementStore.instance
        .announcementById(announcementId);
    if (announcement == null ||
        announcement.status != AnnouncementStatus.published) {
      return Scaffold(
        appBar: AppBar(title: const Text('Announcement')),
        bottomNavigationBar:
            UserProfileStore.instance.profile.value.role ==
                UserProfileRole.admin
            ? const AdminPanelBottomNavigation(
                selected: AdminPanelSection.announcements,
              )
            : null,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This announcement is unavailable.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement Details')),
      bottomNavigationBar:
          UserProfileStore.instance.profile.value.role == UserProfileRole.admin
          ? const AdminPanelBottomNavigation(
              selected: AdminPanelSection.announcements,
            )
          : null,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PUBLISHED ANNOUNCEMENT',
                style: TextStyle(
                  color: AppColors.deepPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Administrator · ${_formatDate(announcement.publishedAt)}',
              style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
            ),
            const Divider(height: 28),
            Text(
              announcement.content,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Official campus information',
              style: TextStyle(
                color: AppColors.deepPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
