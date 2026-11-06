import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/user_profile.dart';
import '../widgets/profile_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final UserProfile _original;
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _programController;
  late final TextEditingController _departmentController;
  late final TextEditingController _semesterController;
  late final TextEditingController _sessionController;
  late UserProfileRole _role;
  late List<String> _skills;
  late List<String> _interests;

  @override
  void initState() {
    super.initState();
    _original = UserProfileStore.instance.profile.value;
    _role = _original.role;
    _nameController = TextEditingController(text: _original.name);
    _locationController = TextEditingController(text: _original.location);
    _bioController = TextEditingController(text: _original.bio);
    _programController = TextEditingController(text: _original.program);
    _departmentController = TextEditingController(text: _original.department);
    _semesterController = TextEditingController(text: _original.semester);
    _sessionController = TextEditingController(text: _original.academicSession);
    _skills = List.of(_original.skills);
    _interests = List.of(_original.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _programController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _sessionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = _original.copyWith(
      name: _nameController.text.trim(),
      role: _role,
      program: _programController.text.trim(),
      semester: _semesterController.text.trim(),
      location: _locationController.text.trim(),
      bio: _bioController.text.trim(),
      department: _departmentController.text.trim(),
      academicSession: _sessionController.text.trim(),
      skills: _skills,
      interests: _interests,
    );
    UserProfileStore.instance.update(updated);
    showProfileMessage(context, 'Profile changes saved locally.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ProfilePageScaffold(
    title: 'Edit Profile',
    actions: [
      TextButton(
        onPressed: _save,
        child: const Text(
          'Save',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
    child: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        children: [
          _photoCard(context),
          const SizedBox(height: 14),
          _personalInformation(),
          const SizedBox(height: 14),
          _academicInformation(),
          const SizedBox(height: 14),
          _tagEditor(
            context,
            title: 'Skills',
            subtitle: 'For FYP partners & hackathon discovery',
            icon: Icons.code,
            tags: _skills,
            onChanged: (value) => setState(() => _skills = value),
          ),
          const SizedBox(height: 14),
          _tagEditor(
            context,
            title: 'Interests',
            subtitle: 'Fields and domains eager to collaborate on',
            icon: Icons.auto_awesome_outlined,
            tags: _interests,
            onChanged: (value) => setState(() => _interests = value),
          ),
          if (_role == UserProfileRole.alumni) ...[
            const SizedBox(height: 12),
            const ProfileCard(
              child: Text(
                'Alumni role selected. Professional fields will be available when supported by the profile design.',
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Cancel'),
            ),
          ),
          const Center(
            child: Text(
              'Profile changes are saved on this device.',
              style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _photoCard(BuildContext context) => ProfileCard(
    child: Column(
      children: [
        const ProfileAvatar(initials: 'AS', radius: 42),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 7,
          children: [
            OutlinedButton.icon(
              onPressed: () => showProfileMessage(
                context,
                'Photo updates are unavailable in this preview.',
              ),
              icon: const Icon(Icons.upload_outlined, size: 15),
              label: const Text('Change Photo'),
            ),
            TextButton.icon(
              onPressed: () => showProfileMessage(
                context,
                'Photo updates are unavailable in this preview.',
              ),
              icon: const Icon(Icons.delete_outline, size: 15),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _personalInformation() {
    final profile = UserProfileStore.instance.profile.value;
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfileSectionHeading(
            title: 'Personal Information',
            icon: Icons.badge_outlined,
          ),
          const Text(
            'Public identity visible across CampConnect',
            style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 11),
          _textField(
            label: 'Full Name',
            controller: _nameController,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your full name.'
                : null,
          ),
          const SizedBox(height: 10),
          _textField(
            label: 'Location',
            controller: _locationController,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your location.'
                : null,
          ),
          const SizedBox(height: 10),
          _textField(
            label: 'About & Bio',
            controller: _bioController,
            maxLines: 4,
            maxLength: 300,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Add a short bio.'
                : null,
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INSTITUTIONAL RECORDS',
                  style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 7),
                _readOnlyRecord(
                  Icons.mail_outline,
                  'Institutional Email',
                  profile.email,
                  'Verified',
                ),
                const SizedBox(height: 6),
                _readOnlyRecord(
                  Icons.badge_outlined,
                  'CMS Registration / Student ID',
                  profile.studentId,
                  'Locked',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _academicInformation() => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionHeading(
          title: 'Academic Information',
          icon: Icons.school_outlined,
        ),
        const Text(
          'Enrolled credentials and faculty status',
          style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 11),
        if (_role == UserProfileRole.admin)
          const ProfileTag('Admin role')
        else ...[
          const Text('Campus Role', style: TextStyle(fontSize: 11)),
          const SizedBox(height: 5),
          SegmentedButton<UserProfileRole>(
            segments: const [
              ButtonSegment(
                value: UserProfileRole.student,
                label: Text('Student'),
              ),
              ButtonSegment(
                value: UserProfileRole.senior,
                label: Text('Senior'),
              ),
              ButtonSegment(
                value: UserProfileRole.alumni,
                label: Text('Alumni'),
              ),
            ],
            selected: {_role},
            onSelectionChanged: (selection) =>
                setState(() => _role = selection.first),
          ),
        ],
        const SizedBox(height: 10),
        const Text('University', style: TextStyle(fontSize: 11)),
        const SizedBox(height: 5),
        _readonlyField(
          Icons.account_balance_outlined,
          UserProfileStore.instance.profile.value.university,
        ),
        const SizedBox(height: 9),
        _textField(
          label: 'Degree Program',
          controller: _programController,
          validator: _requiredValidator('Enter your degree program.'),
        ),
        const SizedBox(height: 9),
        _textField(
          label: 'Department',
          controller: _departmentController,
          validator: _requiredValidator('Enter your department.'),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _textField(
                label: 'Current Semester',
                controller: _semesterController,
                validator: _requiredValidator('Enter your semester.'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _textField(
                label: 'Academic Session',
                controller: _sessionController,
                validator: _requiredValidator('Enter your academic session.'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _tagEditor(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> tags,
    required ValueChanged<List<String>> onChanged,
  }) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeading(
          title: title,
          icon: icon,
          trailing: ProfileTag('${tags.length} Tags'),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final tag in tags)
              InputChip(
                label: Text(tag, style: const TextStyle(fontSize: 10)),
                onDeleted: () =>
                    onChanged(tags.where((entry) => entry != tag).toList()),
                backgroundColor: AppColors.lightBlue,
                deleteIconColor: AppColors.secondaryText,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _addTag(context, title, tags, onChanged),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
          ),
        ),
      ],
    ),
  );

  Future<void> _addTag(
    BuildContext context,
    String title,
    List<String> tags,
    ValueChanged<List<String>> onChanged,
  ) async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter a value'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (tag == null || tag.isEmpty || tags.contains(tag)) return;
    onChanged([...tags, tag]);
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
    int? maxLength,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          isDense: true,
        ),
      ),
    ],
  );

  String? Function(String?) _requiredValidator(String message) =>
      (value) => value == null || value.trim().isEmpty ? message : null;

  Widget _readonlyField(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 17, color: AppColors.secondaryText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        const Icon(Icons.verified, color: AppColors.success, size: 15),
      ],
    ),
  );

  Widget _readOnlyRecord(
    IconData icon,
    String label,
    String value,
    String state,
  ) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: [
        Icon(icon, size: 17, color: AppColors.secondaryText),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 8)),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ProfileTag(state),
      ],
    ),
  );
}
