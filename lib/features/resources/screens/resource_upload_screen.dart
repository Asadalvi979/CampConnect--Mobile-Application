import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../../navigation/app_routes.dart';
import '../models/resource.dart';
import '../models/resource_route_arguments.dart';
import '../services/resource_store.dart';
import '../widgets/resource_widgets.dart';

class ResourceUploadScreen extends StatefulWidget {
  const ResourceUploadScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<ResourceUploadScreen> createState() => _ResourceUploadScreenState();
}

class _ResourceUploadScreenState extends State<ResourceUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  ResourceCategory? _category;
  String _department = 'Computer Science & IT';
  int? _semester = 5;
  MockResourceFile? _file;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewerRole == UserProfileRole.admin) {
      return ResourcePage(
        title: 'Upload Resource',
        child: const ResourceEmptyState(
          title: 'Upload unavailable',
          message: 'Resource uploads are available to student, senior, and alumni accounts.',
        ),
      );
    }
    return ResourcePage(
      title: 'Upload Resource',
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(17, 12, 17, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _honorNotice(),
              const SizedBox(height: 17),
              _label('Resource Title *'),
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: _decoration(
                  hint: 'e.g., Computer Networks Midterm Solved Past Papers',
                  icon: Icons.title,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a resource title.'
                    : null,
              ),
              const SizedBox(height: 9),
              _label('Description *'),
              TextFormField(
                controller: _descriptionController,
                maxLength: 500,
                minLines: 3,
                maxLines: 5,
                decoration: _decoration(
                  hint: 'Describe this resource and what students can learn.',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a resource description.'
                    : null,
              ),
              const SizedBox(height: 9),
              _label('Category *'),
              DropdownButtonFormField<ResourceCategory>(
                isExpanded: true,
                initialValue: _category,
                decoration: _decoration(icon: Icons.category_outlined),
                hint: const Text('Select a category'),
                items: [
                  for (final category in ResourceCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Select a resource category.' : null,
              ),
              const SizedBox(height: 13),
              _label('Subject Name / Course Code *'),
              TextFormField(
                controller: _subjectController,
                decoration: _decoration(
                  hint: 'e.g., Data Structures (CS-201)',
                  icon: Icons.menu_book_outlined,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the subject or course code.'
                    : null,
              ),
              const SizedBox(height: 13),
              _label('Department'),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _department,
                decoration: _decoration(icon: Icons.account_balance_outlined),
                items: const [
                  DropdownMenuItem(
                    value: 'Computer Science & IT',
                    child: Text('Computer Science & IT'),
                  ),
                  DropdownMenuItem(
                    value: 'Software Engineering',
                    child: Text('Software Engineering'),
                  ),
                  DropdownMenuItem(
                    value: 'Electrical Engineering',
                    child: Text('Electrical Engineering'),
                  ),
                  DropdownMenuItem(
                    value: 'Business Administration',
                    child: Text('Business Administration'),
                  ),
                  DropdownMenuItem(value: 'Pharmacy', child: Text('Pharmacy')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _department = value);
                },
              ),
              const SizedBox(height: 13),
              _label('Target Semester'),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _semester,
                decoration: _decoration(icon: Icons.calendar_month_outlined),
                items: [
                  for (var semester = 1; semester <= 8; semester++)
                    DropdownMenuItem(
                      value: semester,
                      child: Text('$semester${_ordinal(semester)} Semester'),
                    ),
                ],
                onChanged: (value) => setState(() => _semester = value),
              ),
              const SizedBox(height: 14),
              _label('Attached Document *'),
              _filePicker(),
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Text(
                  'Mock preview only. Supported examples: PDF, DOCX, PPTX, ZIP (up to 25 MB). No device file is selected or uploaded.',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.deepPrimary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The form checks the mock resource metadata and file type/size. Valid entries are published without mandatory admin pre-approval. Risk checks are not simulated.',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              SizedBox(
                height: 49,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isSubmitting
                        ? 'Publishing locally...'
                        : 'Publish Resource',
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

  Widget _honorNotice() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified_user_outlined, color: AppColors.deepPrimary),
        SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Academic Sharing Honor Code',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                'Share materials that follow academic integrity guidelines. This local preview does not verify user identity or scan files.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );

  InputDecoration _decoration({String? hint, IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
        fillColor: AppColors.white,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );

  Widget _filePicker() => InkWell(
    onTap: _selectMockFile,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _file == null ? AppColors.border : AppColors.success,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _file == null
                ? Icons.cloud_upload_outlined
                : _file!.extension == 'pdf'
                ? Icons.picture_as_pdf_outlined
                : Icons.insert_drive_file_outlined,
            color: _file == null ? AppColors.deepPrimary : AppColors.success,
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _file?.name ?? 'Tap to select a mock document',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _file == null
                      ? 'PDF, DOCX, PPTX or ZIP · up to 25 MB'
                      : '${_file!.extension.toUpperCase()} · ${(_file!.sizeKb / 1024).toStringAsFixed(1)} MB · Local mock',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (_file != null)
            IconButton(
              tooltip: 'Remove mock file',
              onPressed: () => setState(() => _file = null),
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            )
          else
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
        ],
      ),
    ),
  );

  Future<void> _selectMockFile() async {
    final selected = await showModalBottomSheet<MockResourceFile>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Choose a local mock file',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('No real device file will be opened.'),
            ),
            for (final file in const [
              MockResourceFile(
                name: 'Course_Notes.pdf',
                fileType: 'application/pdf',
                sizeKb: 2400,
              ),
              MockResourceFile(
                name: 'Lecture_Slides.pptx',
                fileType: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                sizeKb: 4200,
              ),
              MockResourceFile(
                name: 'Study_Guide.docx',
                fileType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                sizeKb: 1300,
              ),
              MockResourceFile(
                name: 'Lab_Examples.zip',
                fileType: 'application/zip',
                sizeKb: 5800,
              ),
            ])
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(file.name),
                subtitle: Text('${(file.sizeKb / 1024).toStringAsFixed(1)} MB'),
                onTap: () => Navigator.pop(context, file),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _file = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_file == null) {
      _showMessage('Select a mock document before publishing.');
      return;
    }
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    final result = ResourceStore.instance.uploadResource(
      uploaderRole: widget.viewerRole,
      uploaderId: ResourceStore.instance.currentUserId(widget.viewerRole),
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category!,
      subject: _subjectController.text,
      department: _department,
      semester: _semester,
      academicYear: '',
      file: _file,
    );
    setState(() => _isSubmitting = false);
    if (result != ResourceUploadResult.created) {
      _showMessage(switch (result) {
        ResourceUploadResult.invalidRole =>
          'Only eligible campus members can upload resources.',
        ResourceUploadResult.invalidMetadata =>
          'Check the required resource information.',
        ResourceUploadResult.invalidFile =>
          'Use a supported file type and a size up to 25 MB.',
        ResourceUploadResult.created => '',
      });
      return;
    }
    _showMessage(
      'Added to the local preview as Published. No file was uploaded.',
    );
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.resources,
      arguments: ResourceRouteArguments(viewerRole: widget.viewerRole),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  String _ordinal(int value) => switch (value) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}
