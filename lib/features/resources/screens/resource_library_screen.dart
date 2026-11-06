import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource.dart';
import '../services/resource_store.dart';
import '../widgets/resource_navigation.dart';
import '../widgets/resource_widgets.dart';

class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  final _searchController = TextEditingController();
  ResourceCategory? _category;
  String? _department;
  int? _semester;
  String? _subject;
  String? _fileType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ResourceStore.instance;
    return ResourcePage(
      title: 'Resource Library',
      bottomNavigationBar: ResourceBottomBar(viewerRole: widget.viewerRole),
      actions: [
        if (widget.viewerRole == UserProfileRole.admin)
          IconButton(
            tooltip: 'Resource moderation',
            onPressed: () =>
                openResourceModeration(context, viewerRole: widget.viewerRole),
            icon: const Icon(Icons.gavel_outlined),
          ),
        if (widget.viewerRole != UserProfileRole.admin)
          IconButton(
            tooltip: 'My Resources',
            onPressed: () =>
                openMyResources(context, viewerRole: widget.viewerRole),
            icon: const Icon(Icons.folder_open_outlined),
          ),
      ],
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final published = store.publishedResources();
          final filtered = published.where(_matches).toList()
            ..sort(
              (first, second) => second.uploadedAt.compareTo(first.uploadedAt),
            );
          final filteredIds = filtered.map((item) => item.id).toSet();
          final featured = filtered
              .where(
                (item) =>
                    item.id == 'resource-dsa-notes' ||
                    item.id == 'resource-os-notes',
              )
              .toList();
          final recentlyUploaded = filtered
              .where((item) => !featured.contains(item))
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 11, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discover and share academic materials.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search notes, books, documents...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 39,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _categoryChip('All', null),
                          for (final category in ResourceCategory.values)
                            _categoryChip(category.label, category),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showFilters(context),
                        icon: const Icon(Icons.tune, size: 17),
                        label: Text(
                          _hasFilters ? 'Filters applied' : 'Filters',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const ResourceEmptyState(
                        title: 'No resources found',
                        message: 'Try a different search term or clear your filters.',
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(15, 2, 15, 18),
                        children: [
                          if (featured.any(
                            (resource) => filteredIds.contains(resource.id),
                          )) ...[
                            _sectionHeader('Featured Resources'),
                            for (final resource in featured)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: _resourceCard(context, resource),
                              ),
                          ],
                          _sectionHeader('Recently Uploaded'),
                          if (recentlyUploaded.isEmpty &&
                              featured.isNotEmpty &&
                              filtered.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'All matching resources are featured above.',
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          for (final resource in recentlyUploaded)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _resourceCard(context, resource),
                            ),
                        ],
                      ),
              ),
              if (widget.viewerRole != UserProfileRole.admin)
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => openResourceUpload(
                        context,
                        viewerRole: widget.viewerRole,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Upload Resource'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool get _hasFilters =>
      _category != null ||
      _department != null ||
      _semester != null ||
      _subject != null ||
      _fileType != null;

  bool _matches(AcademicResource resource) {
    final query = _searchController.text.trim().toLowerCase();
    return (_category == null || resource.category == _category) &&
        (_department == null || resource.department == _department) &&
        (_semester == null || resource.semester == _semester) &&
        (_subject == null || resource.subject == _subject) &&
        (_fileType == null ||
            resource.fileName.toLowerCase().endsWith('.$_fileType')) &&
        (query.isEmpty ||
            resource.title.toLowerCase().contains(query) ||
            resource.subject.toLowerCase().contains(query) ||
            resource.category.label.toLowerCase().contains(query) ||
            resource.description?.toLowerCase().contains(query) == true);
  }

  Widget _categoryChip(String label, ResourceCategory? category) {
    final selected = _category == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _category = category),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.white,
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.secondaryText,
          fontSize: 10,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(1, 10, 1, 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );

  Widget _resourceCard(BuildContext context, AcademicResource resource) {
    final uploader = ResourceStore.instance.uploaderName(
      resource.uploaderId,
      viewerRole: widget.viewerRole,
    );
    return ResourceCard(
      resource: resource,
      uploaderName: uploader,
      onTap: () => openResourceDetails(
        context,
        resourceId: resource.id,
        viewerRole: widget.viewerRole,
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 5, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Filter Resources',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ResourceCategory?>(
                  isExpanded: true,
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All categories'),
                    ),
                    for (final category in ResourceCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged: (value) => setSheetState(() {
                    _category = value;
                  }),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _department,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (final department in const [
                      'Computer Science & IT',
                      'Software Engineering',
                      'Electrical Engineering',
                      'Business Administration',
                      'Pharmacy',
                    ])
                      DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      ),
                  ],
                  onChanged: (value) => setSheetState(() {
                    _department = value;
                  }),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: _semester,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (var semester = 1; semester <= 8; semester++)
                      DropdownMenuItem(
                        value: semester,
                        child: Text('Semester $semester'),
                      ),
                  ],
                  onChanged: (value) => setSheetState(() {
                    _semester = value;
                  }),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (final subject
                        in ResourceStore.instance
                            .publishedResources()
                            .map((resource) => resource.subject)
                            .where((subject) => subject.isNotEmpty)
                            .toSet())
                      DropdownMenuItem(value: subject, child: Text(subject)),
                  ],
                  onChanged: (value) => setSheetState(() {
                    _subject = value;
                  }),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _fileType,
                  decoration: const InputDecoration(labelText: 'File Type'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                    DropdownMenuItem(value: 'docx', child: Text('DOCX')),
                    DropdownMenuItem(value: 'pptx', child: Text('PPTX')),
                    DropdownMenuItem(value: 'zip', child: Text('ZIP')),
                  ],
                  onChanged: (value) => setSheetState(() {
                    _fileType = value;
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _category = null;
                            _department = null;
                            _semester = null;
                            _subject = null;
                            _fileType = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear filters'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text('Apply filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
