import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../data/project_mock_data.dart';
import '../models/project_opportunity.dart';
import '../services/project_collaboration_store.dart';
import '../widgets/project_widgets.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  Widget build(BuildContext context) =>
      _ProjectFormScreen(viewerRole: viewerRole);
}

class EditProjectScreen extends StatelessWidget {
  const EditProjectScreen({
    required this.viewerRole,
    required this.projectId,
    super.key,
  });

  final UserProfileRole viewerRole;
  final String projectId;

  @override
  Widget build(BuildContext context) =>
      _ProjectFormScreen(viewerRole: viewerRole, projectId: projectId);
}

class _ProjectFormScreen extends StatefulWidget {
  const _ProjectFormScreen({required this.viewerRole, this.projectId});

  final UserProfileRole viewerRole;
  final String? projectId;

  @override
  State<_ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<_ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _skillController = TextEditingController();
  final _store = ProjectCollaborationStore.instance;
  final _skills = <String>[];
  ProjectOpportunity? _project;
  String? _category;
  int _teamSize = 3;
  bool _saving = false;
  bool _initialized = false;

  bool get _isEditing => widget.projectId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final id = widget.projectId;
    if (id == null) return;
    _project = _store.project(id);
    final project = _project;
    if (project == null ||
        project.creatorId != _store.userIdFor(widget.viewerRole)) {
      return;
    }
    _titleController.text = project.title;
    _descriptionController.text = project.description;
    _requirementsController.text = project.teamRequirements;
    _skills.addAll(project.requiredSkills);
    _category = project.category;
    _teamSize = project.desiredTeamSize;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;
    final authorized =
        !_isEditing ||
        (project != null &&
            project.creatorId == _store.userIdFor(widget.viewerRole));
    if (!authorized) {
      return ProjectScaffold(
        title: _isEditing ? 'Edit Project' : 'Create Project',
        viewerRole: widget.viewerRole,
        body: const ProjectEmptyState(
          title: 'Project unavailable',
          message: 'Only the project owner can edit this opportunity.',
        ),
      );
    }

    final currentTeamSize = project == null ? 1 : _store.memberCount(project);
    final sizes = List<int>.generate(
      11,
      (index) => index + 2,
    ).where((size) => size >= currentTeamSize).toList();
    if (!sizes.contains(_teamSize)) _teamSize = sizes.last;

    return ProjectScaffold(
      title: _isEditing ? 'Edit Project' : 'Create Project',
      viewerRole: widget.viewerRole,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.publish_outlined),
              label: Text(
                _saving
                    ? 'Saving...'
                    : _isEditing
                    ? 'Save Changes'
                    : 'Publish Project',
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          children: [
            Text(
              _isEditing
                  ? 'Update your opportunity'
                  : 'Start a new collaboration',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            const Text(
              'Share the project details and the skills you are looking for.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 18),
            _field(
              controller: _titleController,
              label: 'Project Title',
              hint: 'e.g. Campus AI Assistant',
              icon: Icons.title,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 13),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: _decoration(
                'Project Category',
                Icons.category_outlined,
              ),
              items: ProjectMockData.categories
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) =>
                  value == null ? 'Select a project category.' : null,
            ),
            const SizedBox(height: 13),
            _field(
              controller: _descriptionController,
              label: 'Project Description',
              hint: 'Describe the project goal and what the team will build.',
              icon: Icons.description_outlined,
              maxLines: 5,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 13),
            _field(
              controller: _requirementsController,
              label: 'Team Requirements & Roles Needed',
              hint: 'Describe the roles or contributions you need.',
              icon: Icons.groups_outlined,
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 13),
            InputDecorator(
              decoration: _decoration('Required Skills', Icons.code),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_skills.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _skills
                          .map(
                            (skill) => InputChip(
                              label: Text(skill),
                              onDeleted: () =>
                                  setState(() => _skills.remove(skill)),
                            ),
                          )
                          .toList(),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Type a skill and press Add',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      TextButton(
                        onPressed: _addSkill,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_skills.isEmpty)
                    const Text(
                      'Add at least one required skill.',
                      style: TextStyle(color: AppColors.error, fontSize: 11),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            DropdownButtonFormField<int>(
              initialValue: sizes.contains(_teamSize) ? _teamSize : sizes.last,
              decoration: _decoration(
                'Desired Team Size (including you)',
                Icons.people_outline,
              ),
              items: sizes
                  .map(
                    (size) => DropdownMenuItem(
                      value: size,
                      child: Text('$size members'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _teamSize = value);
              },
            ),
            if (_isEditing && project != null) ...[
              const SizedBox(height: 18),
              ProjectCardSurface(
                color: AppColors.paleBlue,
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.deepPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_store.memberCount(project)} current team members. The team size cannot be set below the current team.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_isEditing &&
                project?.status == ProjectOpportunityStatus.active)
              OutlinedButton.icon(
                onPressed: _closeProject,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Close Project'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(46),
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.border),
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    validator: validator,
    maxLines: maxLines,
    textCapitalization: TextCapitalization.sentences,
    decoration: _decoration(label, icon).copyWith(hintText: hint),
  );

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty) return;
    if (_skills.any((value) => value.toLowerCase() == skill.toLowerCase())) {
      _skillController.clear();
      return;
    }
    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      showProjectMessage(
        context,
        'Add at least one required skill.',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    final projectId = widget.projectId;
    final success = projectId == null
        ? _store.createProject(
                creatorRole: widget.viewerRole,
                creatorId: _store.userIdFor(widget.viewerRole),
                title: _titleController.text,
                description: _descriptionController.text,
                category: _category!,
                requiredSkills: _skills,
                teamRequirements: _requirementsController.text,
                desiredTeamSize: _teamSize,
              ) !=
              null
        : _store.updateProject(
            projectId: projectId,
            editorId: _store.userIdFor(widget.viewerRole),
            title: _titleController.text,
            description: _descriptionController.text,
            category: _category!,
            requiredSkills: _skills,
            teamRequirements: _requirementsController.text,
            desiredTeamSize: _teamSize,
          );
    if (!success) {
      setState(() => _saving = false);
      showProjectMessage(
        context,
        'Unable to save this project. Check your permissions and team size.',
        isError: true,
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _closeProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close this project?'),
        content: const Text(
          'Students will no longer be able to submit new interests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close Project'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final closed = _store.closeProject(
      projectId: widget.projectId!,
      ownerId: _store.userIdFor(widget.viewerRole),
    );
    if (closed) {
      Navigator.of(context).pop(true);
    } else {
      showProjectMessage(
        context,
        'Unable to close this project.',
        isError: true,
      );
    }
  }
}
