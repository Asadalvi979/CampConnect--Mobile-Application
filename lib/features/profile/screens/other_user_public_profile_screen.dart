import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mentorship/widgets/mentorship_widgets.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../project_collaboration/widgets/project_widgets.dart';
import '../models/user_profile.dart';
import '../widgets/profile_widgets.dart';

class OtherUserPublicProfileScreen extends StatelessWidget {
  const OtherUserPublicProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) => Scaffold(
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
          onPressed: () =>
              showProfileMessage(context, 'Profile options are a preview.'),
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
              _identityCard(context),
              const SizedBox(height: 12),
              _aboutCard(context),
              const SizedBox(height: 12),
              _educationCard(),
              const SizedBox(height: 12),
              _tagsCard(
                title: 'Skills',
                icon: Icons.code,
                tags: const [
                  'Flutter',
                  'Dart',
                  'Python',
                  'Cloud/AWS',
                  'Firebase',
                  'UI/UX Design',
                  'Docker',
                  'REST APIs',
                ],
              ),
              const SizedBox(height: 12),
              _tagsCard(
                title: 'Interests',
                icon: Icons.lightbulb_outline,
                tags: const [
                  'Mobile Computing',
                  'System Design',
                  'Peer Mentoring',
                  'Machine Learning',
                  'Open Source',
                ],
              ),
              const SizedBox(height: 12),
              _projectsCard(context),
              const SizedBox(height: 12),
              _achievementsCard(),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: const ProfileBottomBar(),
  );

  Widget _identityCard(BuildContext context) => ProfileCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.account_balance_outlined,
            size: 33,
            color: AppColors.deepPrimary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -25),
                child: Row(
                  children: [
                    const ProfileAvatar(
                      initials: 'ZF',
                      radius: 32,
                      badge: true,
                    ),
                    const Spacer(),
                    const ProfileTag('✿ Senior • Peer Mentor'),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 7,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Zainab Fatima',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ProfileTag('Top 1%'),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'BS Software Engineering • 7th Semester',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.deepPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '⌖ Riphah International University • Sahiwal Campus',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.paleBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              '🤝 Connected as Peers',
                              style: TextStyle(fontSize: 9),
                            ),
                          ),
                          Text(
                            '♧ Open for Mentorship',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.paleBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          _PublicStat('38', 'Peers'),
                          _PublicStat('6', 'Projects'),
                          _PublicStat('12', 'Mentored'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => openFriendConversation(
                              context,
                              viewerRole:
                                  UserProfileStore.instance.profile.value.role,
                              peerId: userId,
                            ),
                            icon: const Icon(Icons.chat_outlined, size: 16),
                            label: const Text(
                              'Message',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => openMentorshipDirectory(
                              context,
                              role:
                                  UserProfileStore.instance.profile.value.role,
                            ),
                            icon: const Icon(Icons.school_outlined, size: 15),
                            label: const Text(
                              'Find Alumni Mentor',
                              style: TextStyle(fontSize: 9),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Share profile',
                          onPressed: () => showProfileMessage(
                            context,
                            'Profile sharing is a frontend preview.',
                          ),
                          icon: const Icon(Icons.share_outlined, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _aboutCard(BuildContext context) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeading(
          title: 'About Me',
          icon: Icons.badge_outlined,
          trailing: ProfileTag('Available'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Final-year software engineering student specializing in cloud architectures, Flutter cross-platform development, and UI/UX design. Mentoring junior batches in OOP, Data Structures, and FYP project selection.',
          style: TextStyle(
            fontSize: 11,
            height: 1.5,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 17,
                color: AppColors.deepPrimary,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Open to 1-on-1 Mentorship • FYP Guidance',
                  style: TextStyle(fontSize: 10, color: AppColors.deepPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _educationCard() => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeading(
          title: 'Education',
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Riphah International University',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ProfileTag('3.84 CGPA'),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Faculty of Computing • BS Software Engineering (BSSE)',
                style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
              ),
              SizedBox(height: 8),
              Text(
                'Session 2021–2025  •  Rector’s Honor Scholar',
                style: TextStyle(fontSize: 9, color: AppColors.deepPrimary),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _tagsCard({
    required String title,
    required IconData icon,
    required List<String> tags,
  }) => ProfileCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeading(
          title: title,
          icon: icon,
          trailing: Text(
            '${tags.length} Academic Tags',
            style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags.map((tag) => ProfileTag(tag)).toList(),
        ),
      ],
    ),
  );

  Widget _projectsCard(BuildContext context) => ProfileCard(
    child: Column(
      children: [
        ProfileSectionHeading(
          title: 'Projects (6)',
          icon: Icons.folder_open_outlined,
          trailing: TextButton(
            onPressed: () => openProjectList(
              context,
              UserProfileStore.instance.profile.value.role,
            ),
            child: const Text(
              'Explore Projects ›',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
        const SizedBox(height: 5),
        _project(
          'HealthBridge Telemedicine App',
          'Lead Frontend Developer',
          'Real-time doctor appointment and WebRTC video consult pipeline built with HIPAA-compliant tools.',
          const ['Flutter', 'Firebase', 'WebRTC'],
        ),
        const SizedBox(height: 8),
        _project(
          'Automated Attendance & Face Recognizer',
          'Core ML Engineer',
          'Edge-powered biometric detection system reducing lecture check-in delays by 84%.',
          const ['Python', 'OpenCV', 'SQLite'],
        ),
      ],
    ),
  );

  Widget _project(
    String title,
    String role,
    String description,
    List<String> tags,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(11),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 15),
          ],
        ),
        Text(
          role,
          style: const TextStyle(fontSize: 9, color: AppColors.deepPrimary),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
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
  );

  Widget _achievementsCard() => const ProfileCard(
    child: Column(
      children: [
        ProfileSectionHeading(
          title: 'Achievements',
          icon: Icons.workspace_premium_outlined,
        ),
        SizedBox(height: 9),
        _PublicAchievement(
          icon: Icons.workspace_premium_outlined,
          title: 'Dean’s Honor List',
          detail: '4 Consecutive Semesters • Academic Excellence',
        ),
        SizedBox(height: 7),
        _PublicAchievement(
          icon: Icons.volunteer_activism_outlined,
          title: 'Best Peer Tutor Award 2024',
          detail: 'Recognized by Computing Department',
          accent: AppColors.success,
        ),
      ],
    ),
  );
}

class _PublicStat extends StatelessWidget {
  const _PublicStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
        ),
      ],
    ),
  );
}

class _PublicAchievement extends StatelessWidget {
  const _PublicAchievement({
    required this.icon,
    required this.title,
    required this.detail,
    this.accent = AppColors.deepPrimary,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 23, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
}
