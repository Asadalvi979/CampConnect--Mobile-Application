import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart'
    show UserProfileRole, UserProfileStore;
import '../models/project_interest.dart';
import '../models/project_opportunity.dart';
import '../services/project_collaboration_store.dart';
import '../widgets/project_widgets.dart';

class ExpressInterestScreen extends StatefulWidget {
  const ExpressInterestScreen({
    required this.viewerRole,
    required this.projectId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String projectId;

  @override
  State<ExpressInterestScreen> createState() => _ExpressInterestScreenState();
}

class _ExpressInterestScreenState extends State<ExpressInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _availabilityFieldKey = GlobalKey<FormFieldState<String>>();
  final _messageController = TextEditingController();
  final _store = ProjectCollaborationStore.instance;
  final _selectedSkills = <String>{};
  String? _availability;
  bool _submitting = false;

  static const _availabilityOptions = [
    '1–3 hours per week',
    '4–6 hours per week',
    '5–8 hours per week',
    '8–12 hours per week',
    '12+ hours per week',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = _store.project(widget.projectId);
    if (project == null) {
      return ProjectScaffold(
        title: 'Express Interest',
        viewerRole: widget.viewerRole,
        body: const ProjectEmptyState(
          title: 'Project unavailable',
          message: 'This opportunity may have been removed.',
        ),
      );
    }

    final userId = _store.userIdFor(widget.viewerRole);
    final existing = _store.interest(project.id, userId);
    final canSubmit =
        (widget.viewerRole == UserProfileRole.student ||
            widget.viewerRole == UserProfileRole.senior) &&
        project.creatorId != userId &&
        _store.isRecruiting(project) &&
        existing == null;
    final skills = UserProfileStore.instance.profile.value.skills;

    return ProjectScaffold(
      title: 'Express Interest',
      viewerRole: widget.viewerRole,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canSubmit && !_submitting ? _submit : null,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(_submitting ? 'Submitting...' : 'Submit Interest'),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          children: [
            Text(
              project.title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${project.category} • ${_store.openSpots(project)} open ${_store.openSpots(project) == 1 ? 'place' : 'places'}',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            ProjectCardSurface(
              color: AppColors.paleBlue,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.deepPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tell the project owner how you can contribute. Your interest remains pending until they review it.',
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            if (!canSubmit) ...[
              const SizedBox(height: 12),
              ProjectCardSurface(
                child: Text(
                  _reason(project, existing),
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 18),
            TextFormField(
              controller: _messageController,
              minLines: 4,
              maxLines: 7,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Message to Project Owner',
                hintText: 'Share why this project interests you and how you can contribute.',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 76),
                  child: Icon(Icons.edit_note_outlined),
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              validator: (value) => value == null || value.trim().length < 10
                  ? 'Please write at least 10 characters.'
                  : null,
            ),
            const SizedBox(height: 15),
            const Text(
              'Your Relevant Skills',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select skills from your profile that match this opportunity.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
            ),
            const SizedBox(height: 8),
            if (skills.isEmpty)
              const ProjectEmptyState(
                title: 'No profile skills',
                message: 'Add skills to your profile before applying.',
                icon: Icons.code,
              )
            else
              Wrap(
                spacing: 7,
                runSpacing: 4,
                children: skills.map((skill) {
                  final selected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: selected,
                    onSelected: canSubmit
                        ? (value) => setState(() {
                            if (value) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          })
                        : null,
                  );
                }).toList(),
              ),
            if (_selectedSkills.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  'Select at least one skill.',
                  style: TextStyle(color: AppColors.error, fontSize: 11),
                ),
              ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              key: _availabilityFieldKey,
              initialValue: _availability,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Weekly Availability',
                prefixIcon: const Icon(Icons.schedule_outlined),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              items: _availabilityOptions
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: canSubmit
                  ? (value) => setState(() => _availability = value)
                  : null,
              validator: (value) =>
                  value == null ? 'Select your weekly availability.' : null,
            ),
          ],
        ),
      ),
    );
  }

  String _reason(ProjectOpportunity project, ProjectInterest? existing) {
    if (widget.viewerRole != UserProfileRole.student &&
        widget.viewerRole != UserProfileRole.senior) {
      return 'Only students and seniors can express interest in project opportunities.';
    }
    if (project.creatorId == _store.userIdFor(widget.viewerRole)) {
      return 'You cannot submit interest in your own project.';
    }
    if (existing != null) {
      return 'You have already submitted an interest for this project.';
    }
    if (!_store.isRecruiting(project)) {
      return 'This project is no longer accepting new interests.';
    }
    return 'This project is unavailable for new interests.';
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _selectedSkills.isEmpty || _availability == null) {
      if (_availability == null) _scrollToAvailability();
      if (_selectedSkills.isEmpty) {
        showProjectMessage(
          context,
          'Select at least one relevant skill.',
          isError: true,
        );
      }
      return;
    }
    setState(() => _submitting = true);
    final result = _store.submitInterest(
      projectId: widget.projectId,
      applicantRole: widget.viewerRole,
      applicantId: _store.userIdFor(widget.viewerRole),
      message: _messageController.text,
      selectedSkills: _selectedSkills.toList(),
      weeklyAvailability: _availability!,
    );
    if (result != SubmitProjectResult.created) {
      setState(() => _submitting = false);
      showProjectMessage(context, switch (result) {
        SubmitProjectResult.duplicate =>
          'You have already submitted an interest for this project.',
        SubmitProjectResult.unauthorized =>
          'You are not allowed to submit interest for this project.',
        SubmitProjectResult.closed =>
          'This project is closed to new interests.',
        SubmitProjectResult.full =>
          'This project has no open places remaining.',
        SubmitProjectResult.invalidSkills =>
          'Select skills listed on your profile.',
        SubmitProjectResult.notFound => 'This project is unavailable.',
        SubmitProjectResult.created => 'Your interest was submitted.',
      }, isError: true);
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _scrollToAvailability() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final fieldContext = _availabilityFieldKey.currentContext;
    if (fieldContext == null || !fieldContext.mounted) return;
    await Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 220),
      alignment: 0.8,
    );
    if (mounted) _formKey.currentState?.validate();
  }
}
