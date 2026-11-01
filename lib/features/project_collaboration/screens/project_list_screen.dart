import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/project_interest.dart';
import '../models/project_opportunity.dart';
import '../models/project_route_arguments.dart';
import '../services/project_collaboration_store.dart';
import '../widgets/project_widgets.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';
  String _department = 'All';
  String _skill = 'All';

  ProjectCollaborationStore get _store => ProjectCollaborationStore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProjectScaffold(
    title: 'Project List',
    viewerRole: widget.viewerRole,
    showBottomBar: true,
    actions: [
      IconButton(
        tooltip: 'My projects',
        onPressed: () => openMyProjects(context, widget.viewerRole),
        icon: const Icon(Icons.workspaces_outline),
      ),
    ],
    body: AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final all = _store.activeOpportunities();
        final filtered = _filterProjects(all);
        final featured = filtered.take(2).toList();
        return Stack(
          children: [
            CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _searchAndFilters()),
                if (featured.isNotEmpty)
                  SliverToBoxAdapter(child: _featuredSection(featured)),
                SliverToBoxAdapter(
                  child: _sectionHeader(filtered.length, all.length),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: ProjectEmptyState(
                      title: 'No matching projects',
                      message: 'Try a different search or clear the selected filters.',
                      icon: Icons.search_off,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _projectCard(filtered[index]),
                    ),
                  ),
              ],
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: FloatingActionButton.extended(
                onPressed: () => _createProject(),
                icon: const Icon(Icons.add),
                label: const Text('Create Project'),
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _searchAndFilters() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search projects by title, skill or technology...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Project filters',
              onPressed: _showFilters,
              icon: const Icon(Icons.tune),
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              'All',
              'Web Development',
              'Mobile Application',
              'Artificial Intelligence',
              'Machine Learning',
              'Game Development',
              'Internet of Things',
              'Other',
            ].map(_categoryChip).toList(),
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            if (_department != 'All')
              ProjectPill(_department, color: AppColors.paleBlue),
            if (_skill != 'All') ProjectPill(_skill, color: AppColors.paleBlue),
            if (_department != 'All' || _skill != 'All')
              TextButton(
                onPressed: () => setState(() {
                  _department = 'All';
                  _skill = 'All';
                }),
                child: const Text('Clear filters'),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _categoryChip(String category) {
    final selected = _category == category;
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(
          category == 'Mobile Application' ? 'Mobile Apps' : category,
        ),
        selected: selected,
        onSelected: (_) => setState(() => _category = category),
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.primaryText,
          fontSize: 11,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.lightBlue,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _featuredSection(List<ProjectOpportunity> projects) => Padding(
    padding: const EdgeInsets.only(top: 5, bottom: 5),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Icon(
                Icons.star_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  'Featured Projects',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'Spotlight picks',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 195,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _featuredCard(projects[index]),
          ),
        ),
      ],
    ),
  );

  Widget _featuredCard(ProjectOpportunity project) => SizedBox(
    width: 270,
    child: ProjectCardSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openProjectDetails(context, widget.viewerRole, project.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categoryBanner(project.category, height: 75),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _store
                        .userSummary(
                          project.creatorId,
                          viewerRole: widget.viewerRole,
                        )
                        .name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    children: project.requiredSkills
                        .take(3)
                        .map((skill) => ProjectPill(skill))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _categoryBanner(String category, {double height = 88}) => Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.deepPrimary, AppColors.primary],
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Stack(
      children: [
        const Positioned(
          right: 14,
          top: 8,
          bottom: 0,
          child: Icon(
            Icons.rocket_launch_outlined,
            size: 64,
            color: Color(0x44FFFFFF),
          ),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: ProjectPill(category, color: AppColors.white),
        ),
      ],
    ),
  );

  Widget _sectionHeader(int shownCount, int totalCount) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 13, 18, 9),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Projects',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              Text(
                'Discover active teams building right now',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
            ],
          ),
        ),
        ProjectPill('$shownCount / $totalCount Active'),
      ],
    ),
  );

  Widget _projectCard(ProjectOpportunity project) {
    final ownerId = _store.userIdFor(widget.viewerRole);
    final isOwner = project.creatorId == ownerId;
    final existing = _store.interest(project.id, ownerId);
    final spots = _store.openSpots(project);
    final interestLabel = switch (existing?.status) {
      ProjectInterestStatus.pending => 'Interest Pending',
      ProjectInterestStatus.accepted => 'Accepted',
      ProjectInterestStatus.rejected => 'Rejected',
      null =>
        isOwner
            ? 'Your Project'
            : !_store.isRecruiting(project)
            ? project.status == ProjectOpportunityStatus.closed
                  ? 'Closed'
                  : 'Team Full'
            : 'Express Interest',
    };
    final canExpress =
        !isOwner && _store.isRecruiting(project) && existing == null;

    return ProjectCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProjectPill(_shortCategory(project.category)),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  spots > 0
                      ? '$spots ${spots == 1 ? 'spot' : 'spots'} open'
                      : project.status == ProjectOpportunityStatus.closed
                      ? 'Closed'
                      : 'Team full',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                  ),
                ),
              ),
              Icon(
                isOwner ? Icons.edit_outlined : Icons.bookmark_border,
                color: AppColors.primaryText,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              ProjectAvatar(
                _store
                    .userSummary(
                      project.creatorId,
                      viewerRole: widget.viewerRole,
                    )
                    .name,
                radius: 16,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _store
                          .userSummary(
                            project.creatorId,
                            viewerRole: widget.viewerRole,
                          )
                          .name,
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      '${_store.userSummary(project.creatorId, viewerRole: widget.viewerRole).roleLabel} • ${_store.userSummary(project.creatorId, viewerRole: widget.viewerRole).semester}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              ProjectPill(
                '${_store.memberCount(project)}/${project.desiredTeamSize} members',
                color: AppColors.paleBlue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: project.requiredSkills
                .take(4)
                .map((skill) => ProjectPill(skill, color: AppColors.paleBlue))
                .toList(),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => openProjectDetails(
                    context,
                    widget.viewerRole,
                    project.id,
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: canExpress
                      ? () => _openInterest(project.id)
                      : isOwner
                      ? () => openProjectDetails(
                          context,
                          widget.viewerRole,
                          project.id,
                        )
                      : existing != null
                      ? () => openProjectDetails(
                          context,
                          widget.viewerRole,
                          project.id,
                        )
                      : null,
                  child: Text(
                    interestLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<ProjectOpportunity> _filterProjects(List<ProjectOpportunity> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items.where((project) {
      final owner = _store.userSummary(
        project.creatorId,
        viewerRole: widget.viewerRole,
      );
      final matchesSearch =
          query.isEmpty ||
          <String>[
            project.title,
            project.description,
            project.category,
            owner.name,
            ...project.requiredSkills,
          ].any((value) => value.toLowerCase().contains(query));
      final matchesCategory =
          _category == 'All' || project.category == _category;
      final matchesDepartment =
          _department == 'All' || owner.department == _department;
      final matchesSkill =
          _skill == 'All' ||
          project.requiredSkills.any(
            (skill) => skill.toLowerCase() == _skill.toLowerCase(),
          );
      return matchesSearch &&
          matchesCategory &&
          matchesDepartment &&
          matchesSkill;
    }).toList();
  }

  String _shortCategory(String category) => switch (category) {
    'Artificial Intelligence' => 'AI Assistant',
    'Machine Learning' => 'Machine Learning',
    'Web Development' => 'Web Platform',
    'Mobile Application' => 'Mobile App',
    'Internet of Things' => 'IoT & Mobile',
    _ => category,
  };

  Future<void> _createProject() async {
    final created = await Navigator.of(context).pushNamed<dynamic>(
      AppRoutes.projectCreate,
      arguments: ProjectRouteArguments(viewerRole: widget.viewerRole),
    );
    if (mounted && created == true) {
      showProjectMessage(context, 'Project published locally.');
    }
  }

  Future<void> _openInterest(String projectId) async {
    final submitted = await Navigator.of(context).pushNamed<dynamic>(
      AppRoutes.projectExpressInterest,
      arguments: ProjectRouteArguments(
        viewerRole: widget.viewerRole,
        projectId: projectId,
      ),
    );
    if (mounted && submitted == true) {
      showProjectMessage(context, 'Project interest submitted.');
    }
  }

  Future<void> _showFilters() async {
    var department = _department;
    var skill = _skill;
    final departments = {
      'All',
      ..._store.activeOpportunities().map(
        (project) => _store
            .userSummary(project.creatorId, viewerRole: widget.viewerRole)
            .department,
      ),
    }.toList();
    final skills = {
      'All',
      ..._store.activeOpportunities().expand(
        (project) => project.requiredSkills,
      ),
    }.toList()..sort();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Filter projects',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  'Department',
                  department,
                  departments,
                  (value) => setSheetState(() => department = value),
                ),
                _dropdown(
                  'Required skills',
                  skill,
                  skills,
                  (value) => setSheetState(() => skill = value),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _department = department;
                      _skill = skill;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply filters'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _department = 'All';
                      _skill = 'All';
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    ),
  );
}
