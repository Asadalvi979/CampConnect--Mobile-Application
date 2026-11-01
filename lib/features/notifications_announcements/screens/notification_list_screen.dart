import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/campus_notification.dart';
import '../services/notification_announcement_store.dart';

enum _NotificationFilter { all, unread, read }

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = NotificationAnnouncementStore.instance;
    final userId = store.userIdFor(widget.viewerRole);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _filterChip('All', _NotificationFilter.all),
                  const SizedBox(width: 8),
                  _filterChip(
                    'Unread (${store.unreadCountFor(userId)})',
                    _NotificationFilter.unread,
                  ),
                  const SizedBox(width: 8),
                  _filterChip('Read', _NotificationFilter.read),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final items = store.notificationsFor(userId).where((notification) {
              return switch (_filter) {
                _NotificationFilter.all => true,
                _NotificationFilter.unread => !notification.isRead,
                _NotificationFilter.read => notification.isRead,
              };
            }).toList();
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.deepPrimary,
                        size: 46,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _filter == _NotificationFilter.unread
                            ? 'You’re all caught up'
                            : 'No notifications yet',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Relevant campus activity will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final notification = items[index];
                return _notificationCard(
                  notification,
                  onTap: notification.isRead
                      ? null
                      : () => store.markAsRead(
                          notificationId: notification.notificationId,
                          userId: userId,
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _filterChip(String label, _NotificationFilter filter) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = filter),
      selectedColor: AppColors.lightBlue,
      labelStyle: TextStyle(
        color: selected ? AppColors.deepPrimary : AppColors.secondaryText,
        fontSize: 11,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _notificationCard(
    CampusNotification notification, {
    required VoidCallback? onTap,
  }) {
    final unread = !notification.isRead;
    return Material(
      color: unread ? AppColors.paleBlue : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unread ? AppColors.lightBlue : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightBlue,
                child: Icon(
                  _iconFor(notification.type),
                  color: AppColors.deepPrimary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.type,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(notification.createdAt),
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
    'Message request' => Icons.chat_bubble_outline,
    'Mentorship' => Icons.handshake_outlined,
    'Project application' => Icons.folder_open_outlined,
    'Announcement' => Icons.campaign_outlined,
    _ => Icons.notifications_none_rounded,
  };

  String _formatDate(DateTime date) =>
      '${_month(date.month)} ${date.day}, ${date.year} · ${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}';

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
