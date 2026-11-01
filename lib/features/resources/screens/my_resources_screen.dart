import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/resource.dart';
import '../services/resource_store.dart';
import '../widgets/resource_navigation.dart';
import '../widgets/resource_widgets.dart';

class MyResourcesScreen extends StatefulWidget {
  const MyResourcesScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<MyResourcesScreen> createState() => _MyResourcesScreenState();
}

class _MyResourcesScreenState extends State<MyResourcesScreen> {
  final _searchController = TextEditingController();
  ResourceStatus? _status;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ResourceStore.instance;
    final uploaderId = store.currentUserId(widget.viewerRole);
    return ResourcePage(
      title: 'My Resources',
      bottomNavigationBar: ResourceBottomBar(
        viewerRole: widget.viewerRole,
        active: 'Resources',
      ),
      actions: [
        IconButton(
          tooltip: 'Resource Library',
          onPressed: () =>
              openResourceLibrary(context, viewerRole: widget.viewerRole),
          icon: const Icon(Icons.search),
        ),
      ],
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final all = store.resourcesForUploader(uploaderId);
          final visible = all.where((resource) {
            final query = _searchController.text.trim().toLowerCase();
            return (_status == null || resource.status == _status) &&
                (query.isEmpty ||
                    resource.title.toLowerCase().contains(query) ||
                    resource.subject.toLowerCase().contains(query));
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage your shared academic materials',
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
                        hintText: 'Search my resources',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _statusChip('All', null, all.length),
                        for (final status in ResourceStatus.values)
                          _statusChip(
                            status.label,
                            status,
                            all.where((item) => item.status == status).length,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? ResourceEmptyState(
                        title: _status == null
                            ? 'No resources found'
                            : 'No ${_status!.label} resources',
                        message: 'There are no materials matching this search or status.',
                        icon: Icons.folder_off_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(15, 7, 15, 16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 9),
                        itemBuilder: (context, index) {
                          final resource = visible[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ResourceCard(
                                resource: resource,
                                uploaderName: store.uploaderName(
                                  resource.uploaderId,
                                  viewerRole: widget.viewerRole,
                                ),
                                showStatus: true,
                                onTap: () => openResourceStatus(
                                  context,
                                  resourceId: resource.id,
                                  viewerRole: widget.viewerRole,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 4,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => openResourceStatus(
                                      context,
                                      resourceId: resource.id,
                                      viewerRole: widget.viewerRole,
                                    ),
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('View Status'),
                                  ),
                                  if (resource.status ==
                                      ResourceStatus.published)
                                    TextButton.icon(
                                      onPressed: () => openResourceDetails(
                                        context,
                                        resourceId: resource.id,
                                        viewerRole: widget.viewerRole,
                                      ),
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 15,
                                      ),
                                      label: const Text('View Details'),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => openResourceUpload(
                      context,
                      viewerRole: widget.viewerRole,
                    ),
                    icon: const Icon(Icons.cloud_upload_outlined),
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

  Widget _statusChip(String label, ResourceStatus? status, int count) {
    final selected = _status == status;
    return ChoiceChip(
      label: Text('$label $count'),
      selected: selected,
      onSelected: (_) => setState(() => _status = status),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.paleBlue,
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.deepPrimary,
        fontSize: 10,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

extension on ResourceStatus {
  String get label => switch (this) {
    ResourceStatus.published => 'Published',
    ResourceStatus.underReview => 'Under Review',
    ResourceStatus.restricted => 'Restricted',
    ResourceStatus.removed => 'Removed',
  };
}
