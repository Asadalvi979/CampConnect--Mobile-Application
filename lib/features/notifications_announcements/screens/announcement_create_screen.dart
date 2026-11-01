import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../admin_panel/widgets/admin_panel_layout.dart';
import '../../profile/models/user_profile.dart';
import '../services/notification_announcement_store.dart';

class AnnouncementCreateScreen extends StatefulWidget {
  const AnnouncementCreateScreen({super.key});

  @override
  State<AnnouncementCreateScreen> createState() =>
      _AnnouncementCreateScreenState();
}

class _AnnouncementCreateScreenState extends State<AnnouncementCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _publishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileStore.instance.profile.value;
    if (profile.role != UserProfileRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Announcement')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Admin access is required to create announcements.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Create Announcement')),
      bottomNavigationBar: const AdminPanelBottomNavigation(
        selected: AdminPanelSection.announcements,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            children: [
              const Text(
                'Share an official update with the campus community.',
                style: TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
              const SizedBox(height: 18),
              const Text(
                'Title',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration('Enter announcement title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an announcement title.'
                    : null,
              ),
              const SizedBox(height: 13),
              const Text(
                'Content',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                minLines: 6,
                maxLines: 12,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration('Write the announcement details'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter announcement content.'
                    : null,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Publishing makes this announcement visible in the local preview. It does not send a push notification.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _publishing ? null : _publish,
                  icon: _publishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _publishing
                        ? 'Publishing locally...'
                        : 'Publish Announcement',
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
  );

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _publishing = true);
    final profile = UserProfileStore.instance.profile.value;
    final result = NotificationAnnouncementStore.instance
        .createAndPublishAnnouncement(
          role: profile.role,
          adminId: NotificationAnnouncementStore.instance.userIdFor(
            profile.role,
          ),
          title: _titleController.text,
          content: _contentController.text,
        );
    if (!mounted) return;
    setState(() => _publishing = false);
    if (result == AnnouncementPublishResult.published) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == AnnouncementPublishResult.unauthorized
                ? 'Admin access is required.'
                : 'Check the title and announcement content.',
          ),
        ),
      );
    }
  }
}
