import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/alumni_mentor.dart';
import '../services/mentorship_store.dart';
import '../widgets/mentorship_widgets.dart';

class RequestMentorshipScreen extends StatefulWidget {
  const RequestMentorshipScreen({
    required this.alumniId,
    required this.viewerRole,
    super.key,
  });

  final String alumniId;
  final UserProfileRole viewerRole;

  @override
  State<RequestMentorshipScreen> createState() =>
      _RequestMentorshipScreenState();
}

class _RequestMentorshipScreenState extends State<RequestMentorshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String? _focusArea;
  String? _cadence;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentor = MentorshipStore.instance.mentorById(widget.alumniId);
    if (mentor == null) {
      return MentorshipPage(
        title: 'Request Mentorship',
        child: const MentorshipEmptyState(
          title: 'Alumni profile unavailable',
          message: 'Return to the directory and select an available alumnus.',
        ),
      );
    }

    return MentorshipPage(
      title: 'Request Mentorship',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            _mentorSummary(mentor),
            const SizedBox(height: 17),
            const Text(
              'Tell us what you are looking for',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            const Text(
              'A thoughtful request helps your mentor understand how to support you.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 17),
            DropdownButtonFormField<String>(
              initialValue: _focusArea,
              decoration: const InputDecoration(
                labelText: 'Mentorship area *',
                prefixIcon: Icon(Icons.track_changes_outlined),
                border: OutlineInputBorder(),
              ),
              items: mentor.focusAreas
                  .map(
                    (area) => DropdownMenuItem(value: area, child: Text(area)),
                  )
                  .toList(),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Select an area' : null,
              onChanged: (value) => setState(() => _focusArea = value),
            ),
            const SizedBox(height: 13),
            DropdownButtonFormField<String>(
              initialValue: _cadence,
              decoration: const InputDecoration(
                labelText: 'Preferred meeting cadence *',
                prefixIcon: Icon(Icons.calendar_month_outlined),
                border: OutlineInputBorder(),
              ),
              items: const ['Weekly', 'Bi-weekly', 'Monthly']
                  .map(
                    (cadence) =>
                        DropdownMenuItem(value: cadence, child: Text(cadence)),
                  )
                  .toList(),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Select a cadence' : null,
              onChanged: (value) => setState(() => _cadence = value),
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _messageController,
              minLines: 5,
              maxLines: 7,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Personal message *',
                hintText:
                    'Introduce yourself and share what you hope to learn...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Add a short personal message';
                }
                if (value.trim().length < 20) {
                  return 'Please write at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 7),
            OutlinedButton.icon(
              onPressed: () => showMentorshipMessage(
                context,
                'File attachments are not available in this frontend preview.',
              ),
              icon: const Icon(Icons.attach_file),
              label: const Text('Add attachment (optional)'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your request will be visible to this alumnus. You can withdraw it while it is still pending.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : () => _submit(mentor),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(_isSubmitting ? 'Sending...' : 'Send request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mentorSummary(AlumniMentor mentor) => MentorshipCard(
    child: Row(
      children: [
        MentorAvatar(mentor.name, radius: 25),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mentor.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                mentor.headline,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.verified, color: AppColors.success, size: 18),
      ],
    ),
  );

  void _submit(AlumniMentor mentor) {
    if (!_formKey.currentState!.validate()) return;
    if (widget.viewerRole != UserProfileRole.student &&
        widget.viewerRole != UserProfileRole.senior) {
      showMentorshipMessage(
        context,
        'Only Students and Seniors can request mentorship.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final store = MentorshipStore.instance;
    final result = store.createRequest(
      requesterRole: widget.viewerRole,
      requesterId: store.userIdFor(widget.viewerRole),
      alumniId: mentor.id,
      focusArea: _focusArea!,
      cadence: _cadence!,
      message: _messageController.text,
    );
    setState(() => _isSubmitting = false);

    switch (result) {
      case RequestCreationResult.created:
        Navigator.of(context).pop(true);
      case RequestCreationResult.duplicate:
        showMentorshipMessage(
          context,
          'A pending or accepted request already exists for this alumnus.',
          isError: true,
        );
      case RequestCreationResult.unavailable:
        showMentorshipMessage(
          context,
          'This alumnus is not accepting mentorship requests.',
          isError: true,
        );
      case RequestCreationResult.unauthorized:
        showMentorshipMessage(
          context,
          'Only Students and Seniors can request mentorship.',
          isError: true,
        );
    }
  }
}
