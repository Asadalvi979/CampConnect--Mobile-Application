import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/alumni_mentor.dart';
import '../services/mentorship_store.dart';
import '../widgets/mentorship_widgets.dart';

class AlumniDirectoryScreen extends StatefulWidget {
  const AlumniDirectoryScreen({required this.viewerRole, super.key});

  final UserProfileRole viewerRole;

  @override
  State<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends State<AlumniDirectoryScreen> {
  final _searchController = TextEditingController();
  String _focus = 'All';
  String _industry = 'All';
  String _company = 'All';
  String _graduationYear = 'All';

  MentorshipStore get _store => MentorshipStore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MentorshipPage(
    title: 'Alumni Directory',
    actions: [
      IconButton(
        tooltip: 'Mentorship requests',
        onPressed: () =>
            openMentorshipRequests(context, role: widget.viewerRole),
        icon: const Icon(Icons.inbox_outlined),
      ),
      IconButton(
        tooltip: 'Active mentorships',
        onPressed: () =>
            openActiveMentorships(context, role: widget.viewerRole),
        icon: const Icon(Icons.handshake_outlined),
      ),
    ],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find your mentor',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Learn from alumni who have been where you are.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search name, company, or skill',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Filter alumni',
                    onPressed: _showFilters,
                    icon: const Icon(Icons.tune),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    'All',
                    'Software Engineering',
                    'Artificial Intelligence',
                    'Cloud Computing',
                    'Product Design',
                  ].map(_focusChip).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recommended alumni',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${_filteredMentors.length} mentors',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredMentors.isEmpty
              ? const MentorshipEmptyState(
                  title: 'No alumni found',
                  message: 'Try a different search or clear your filters.',
                  icon: Icons.search_off,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                  itemCount: _filteredMentors.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _mentorCard(_filteredMentors[index]),
                ),
        ),
      ],
    ),
  );

  List<AlumniMentor> get _filteredMentors {
    final query = _searchController.text.trim().toLowerCase();
    return _store.alumni.where((mentor) {
      final matchesQuery =
          query.isEmpty ||
          <String>[
            mentor.name,
            mentor.jobTitle,
            mentor.company,
            mentor.industry,
            mentor.department,
            ...mentor.skills,
            ...mentor.focusAreas,
          ].any((value) => value.toLowerCase().contains(query));
      final matchesFocus =
          _focus == 'All' ||
          mentor.focusAreas.any((area) => area == _focus) ||
          mentor.industry == _focus;
      final matchesIndustry =
          _industry == 'All' || mentor.industry == _industry;
      final matchesCompany = _company == 'All' || mentor.company == _company;
      final matchesGraduation =
          _graduationYear == 'All' ||
          mentor.graduationYear.toString() == _graduationYear;
      return matchesQuery &&
          matchesFocus &&
          matchesIndustry &&
          matchesCompany &&
          matchesGraduation;
    }).toList();
  }

  Widget _focusChip(String label) {
    final selected = _focus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _focus = label),
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.deepPrimary,
          fontSize: 11,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.lightBlue,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _mentorCard(AlumniMentor mentor) => MentorshipCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MentorAvatar(mentor.name, radius: 25),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mentor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  Text(
                    mentor.headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${mentor.industry}  ·  Class of ${mentor.graduationYear}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.deepPrimary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          mentor.bio,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: mentor.skills.take(3).map(MentorshipTag.new).toList(),
        ),
        const SizedBox(height: 11),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xFFE9A23B), size: 16),
                const SizedBox(width: 3),
                Text(
                  '${mentor.rating} (${mentor.reviewCount})',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            Text(
              '${mentor.yearsExperience} yrs experience',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
              ),
            ),
            TextButton(
              onPressed: () => openAlumniProfile(
                context,
                role: widget.viewerRole,
                alumniId: mentor.id,
              ),
              child: const Text('View profile'),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _showFilters() async {
    var industry = _industry;
    var company = _company;
    var graduationYear = _graduationYear;
    final industries = {
      'All',
      ..._store.alumni.map((mentor) => mentor.industry),
    }.toList();
    final companies = {
      'All',
      ..._store.alumni.map((mentor) => mentor.company),
    }.toList();
    final graduationYears =
        {
          'All',
          ..._store.alumni.map((mentor) => mentor.graduationYear.toString()),
        }.toList()..sort((first, second) {
          if (first == 'All') return -1;
          if (second == 'All') return 1;
          return second.compareTo(first);
        });

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Filter alumni',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _filterDropdown(
                  'Industry',
                  industry,
                  industries,
                  (value) => setSheetState(() => industry = value),
                ),
                _filterDropdown(
                  'Company',
                  company,
                  companies,
                  (value) => setSheetState(() => company = value),
                ),
                _filterDropdown(
                  'Graduation year',
                  graduationYear,
                  graduationYears,
                  (value) => setSheetState(() => graduationYear = value),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _industry = industry;
                      _company = company;
                      _graduationYear = graduationYear;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply filters'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _industry = 'All';
                      _company = 'All';
                      _graduationYear = 'All';
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

  Widget _filterDropdown(
    String label,
    String selected,
    List<String> options,
    ValueChanged<String> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    ),
  );
}
