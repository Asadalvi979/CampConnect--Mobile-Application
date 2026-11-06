import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home_dashboard/models/dashboard_role.dart';
import '../../navigation/app_routes.dart';
import '../../project_collaboration/widgets/project_widgets.dart';
import '../models/user_profile.dart';
import '../widgets/profile_widgets.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileStore.instance.profile,
      builder: (context, profile, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('User Profile', style: TextStyle(fontSize: 17)),
          actions: [
            IconButton(
              tooltip: 'More options',
              onPressed: () => showProfileMessage(context, 'Profile options'),
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 22),
                children: [
                  _identityCard(context, profile),
                  const SizedBox(height: 12),
                  _aboutCard(context, profile),
                  const SizedBox(height: 12),
                  _educationCard(profile),
                  const SizedBox(height: 12),
                  _skillsCard(profile),
                  const SizedBox(height: 12),
                  _interestsCard(profile),
                  const SizedBox(height: 12),
                  _projectsCard(context, profile),
                  const SizedBox(height: 12),
                  _achievementsCard(profile),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: ProfileBottomBar(
          homeRoute: AppRoutes.dashboardRouteFor(
            dashboardRoleFor(profile.role),
          ),
        ),
      ),
    );
  }

  Widget _identityCard(BuildContext context, UserProfile profile) {
    final isSenior = profile.role == UserProfileRole.senior;
    return ProfileCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials(profile.name),
                  style: const TextStyle(
                    color: AppColors.deepPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: -1,
                bottom: 1,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ProfileTag(profile.roleLabel),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${profile.program} • ${profile.semester}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '⌖ ${profile.university} • ${profile.location.split(',').first}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                _stat('14', 'Peers'),
                _stat('3', 'Projects'),
                _stat(
                  isSenior ? '12' : '5',
                  isSenior ? 'Mentored' : 'Verified',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openEdit(context),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => showProfileMessage(
                  context,
                  'Profile sharing is a frontend preview.',
                ),
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('Share'),
              ),
              IconButton(
                tooltip: 'Profile Settings',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.profileSettings),
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.of(context).pushNamed<void>(AppRoutes.editProfile);
  }

  Widget _stat(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.deepPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
        ),
      ],
    ),
  );

  Widget _aboutCard(BuildContext context, UserProfile profile) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeading(
          title: 'About Me',
          icon: Icons.badge_outlined,
          trailing: ProfileTag('Available'),
        ),
        const SizedBox(height: 9),
        Text(
          profile.bio,
          style: const TextStyle(
            fontSize: 11,
            height: 1.5,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 9),
        ActionChip(
          avatar: const Icon(Icons.groups_outlined, size: 14),
          label: const Text(
            'Open to FYP collaboration & Mentorship',
            style: TextStyle(fontSize: 9),
          ),
          backgroundColor: AppColors.paleBlue,
          side: BorderSide.none,
          onPressed: () => showProfileMessage(
            context,
            'Availability preferences are managed in Profile Settings.',
          ),
        ),
      ],
    ),
  );

  Widget _educationCard(UserProfile profile) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeading(
          title: 'Education',
          icon: Icons.school_outlined,
          trailing: ProfileTag('CGPA: ${profile.cgpa}'),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: AppColors.deepPrimary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.university,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Sahiwal Campus • ${profile.department}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      profile.program,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.deepPrimary,
                      ),
                    ),
                    Text(
                      '${profile.semester} (Session ${profile.academicSession})',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const ProfileTag('★ Honor Roll Dean’s Scholar'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _skillsCard(UserProfile profile) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeading(
          title: 'Skills',
          icon: Icons.code,
          trailing: Text(
            '${profile.skills.length} Academic Tags',
            style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: profile.skills.map((skill) => ProfileTag(skill)).toList(),
        ),
      ],
    ),
  );

  Widget _interestsCard(UserProfile profile) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeading(
          title: 'Interests',
          icon: Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: profile.interests.map((item) => ProfileTag(item)).toList(),
        ),
      ],
    ),
  );

  Widget _projectsCard(
    BuildContext context,
    UserProfile profile,
  ) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeading(
          title: 'My Projects',
          icon: Icons.folder_open_outlined,
          trailing: TextButton(
            onPressed: () => openMyProjects(context, profile.role),
            child: const Text('View All ›', style: TextStyle(fontSize: 10)),
          ),
        ),
        const SizedBox(height: 5),
        _project(
          context,
          title: 'CampConnect Mobile App',
          role: 'Lead Mobile Developer',
          description:
              'A cross-platform Flutter application facilitating academic collaboration, peer mentorship, and resource sharing for ${profile.university}.',
          tags: const ['Flutter', 'Firebase', 'Dart'],
        ),
        const SizedBox(height: 8),
        _project(
          context,
          title: 'Smart Campus Parking & IoT',
          role: 'Backend & Embedded Logic',
          description: 'Automated RFID & sensor-driven parking availability system integrated with university student CMS.',
          tags: const ['Python', 'IoT', 'C++', 'MySQL'],
        ),
        const SizedBox(height: 7),
        Center(
          child: TextButton.icon(
            onPressed: () => openProjectCreate(context, profile.role),
            icon: const Icon(Icons.add_circle_outline, size: 15),
            label: const Text(
              'Add New Project',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _project(
    BuildContext context, {
    required String title,
    required String role,
    required String description,
    required List<String> tags,
  }) => InkWell(
    onTap: () => Navigator.of(context).pushNamed(
      AppRoutes.publicProfile,
      arguments: const PublicProfileArguments(userId: 'senior-zainab'),
    ),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.deepPrimary,
              ),
            ],
          ),
          Text(
            role,
            style: const TextStyle(fontSize: 9, color: AppColors.deepPrimary),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              fontSize: 9,
              height: 1.45,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 8)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );

  Widget _achievementsCard(UserProfile profile) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeading(
          title: 'Achievements',
          icon: Icons.workspace_premium_outlined,
        ),
        const SizedBox(height: 8),
        _achievement(
          '🏆',
          'Dean’s Honor List – Fall 2023',
          'Awarded for exceptional academic GPA of 3.8+ in Software Engineering.',
        ),
        const SizedBox(height: 7),
        _achievement(
          '🏅',
          profile.role == UserProfileRole.senior
              ? 'Best Peer Tutor Award 2024'
              : 'Speed Programming Runner-Up',
          'Campus Tech Colloquium 2024 – Competitive algorithmic problem solving.',
        ),
      ],
    ),
  );

  Widget _achievement(String icon, String title, String detail) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }
}

class PublicProfileArguments {
  const PublicProfileArguments({required this.userId});

  final String userId;
}

DashboardRole dashboardRoleFor(UserProfileRole role) => switch (role) {
  UserProfileRole.student => DashboardRole.student,
  UserProfileRole.senior => DashboardRole.senior,
  UserProfileRole.alumni => DashboardRole.alumni,
  UserProfileRole.admin => DashboardRole.student,
};
