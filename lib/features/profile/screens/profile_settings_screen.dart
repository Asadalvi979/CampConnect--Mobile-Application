import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../models/user_profile.dart';
import '../widgets/profile_widgets.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _appNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UserProfile>(
    valueListenable: UserProfileStore.instance.profile,
    builder: (context, profile, _) => ProfilePageScaffold(
      title: 'Edit Profile',
      actions: [
        IconButton(
          tooltip: 'Profile',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Manage your institutional account & preferences',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: AppColors.lightBlue,
                child: Icon(
                  Icons.manage_accounts_outlined,
                  color: AppColors.deepPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _identityCard(profile),
          const SizedBox(height: 18),
          _settingsGroup(
            title: 'ACCOUNT',
            subtitle: 'Academic Identity',
            rows: [
              _settingsRow(
                context,
                icon: Icons.badge_outlined,
                title: 'Edit Profile',
                detail: 'Update personal and academic information',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.editProfile),
              ),
              _settingsRow(
                context,
                icon: Icons.tune,
                title: 'Profile Settings',
                detail: 'Manage directory visibility & preferences',
                onTap: () => showProfileMessage(
                  context,
                  'You are viewing Profile Settings.',
                ),
              ),
              _settingsRow(
                context,
                icon: Icons.lock_person_outlined,
                title: 'Account Information',
                detail: 'View student credentials & login security',
                onTap: () => showProfileMessage(
                  context,
                  'Account credentials are shown in Edit Profile.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _settingsGroup(
            title: 'NOTIFICATIONS',
            subtitle: 'Real-time alerts',
            rows: [
              _settingsRow(
                context,
                icon: Icons.notifications_none,
                title: 'App Notifications',
                detail: 'Mentorship alerts, peer messages & updates',
                trailing: Switch(
                  value: _appNotifications,
                  onChanged: (value) => setState(() {
                    _appNotifications = value;
                    _feedback('App notifications', value);
                  }),
                ),
                onTap: () => setState(() {
                  _appNotifications = !_appNotifications;
                  _feedback('App notifications', _appNotifications);
                }),
              ),
              _settingsRow(
                context,
                icon: Icons.mail_outline,
                title: 'Email Notifications',
                detail: 'Weekly digests and campus announcements',
                trailing: Switch(
                  value: _emailNotifications,
                  onChanged: (value) => setState(() {
                    _emailNotifications = value;
                    _feedback('Email notifications', value);
                  }),
                ),
                onTap: () => setState(() {
                  _emailNotifications = !_emailNotifications;
                  _feedback('Email notifications', _emailNotifications);
                }),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _settingsGroup(
            title: 'SUPPORT',
            subtitle: 'Helpdesk & Policies',
            rows: [
              _settingsRow(
                context,
                icon: Icons.contact_support_outlined,
                title: 'Help & Support',
                detail: 'Campus IT helpdesk, guides & FAQs',
                onTap: () => showProfileMessage(
                  context,
                  'Campus support destinations are not implemented yet.',
                ),
              ),
              _settingsRow(
                context,
                icon: Icons.info_outline,
                title: 'About CampConnect',
                detail: 'Riphah Sahiwal Campus Edition • v1.2.0',
                onTap: () => showProfileMessage(
                  context,
                  'CampConnect institutional frontend preview.',
                ),
              ),
              _settingsRow(
                context,
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                detail: 'View student data protection guidelines',
                onTap: () => showProfileMessage(
                  context,
                  'Privacy policy content is not available in this preview.',
                ),
              ),
              _settingsRow(
                context,
                icon: Icons.gavel_outlined,
                title: 'Terms & Conditions',
                detail: 'University digital conduct guidelines',
                onTap: () => showProfileMessage(
                  context,
                  'Terms content is not available in this preview.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _settingsRow(
            context,
            icon: Icons.logout,
            title: 'Log Out',
            detail: 'Sign out of your active session on this device',
            isDanger: true,
            onTap: () {
              UserProfileStore.instance.setRole(UserProfileRole.student);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
          const SizedBox(height: 18),
          const Column(
            children: [
              Text(
                '◈  CampConnect Institutional Suite',
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              SizedBox(height: 5),
              Text(
                'Riphah International University • Sahiwal Campus',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
              ),
              SizedBox(height: 5),
              Text(
                'Security features planned for backend integration',
                style: TextStyle(fontSize: 9, color: AppColors.secondaryText),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _identityCard(UserProfile profile) => ProfileCard(
    child: Column(
      children: [
        Row(
          children: [
            ProfileAvatar(
              initials: profile.name
                  .split(' ')
                  .take(2)
                  .map((part) => part[0])
                  .join()
                  .toUpperCase(),
              radius: 25,
              badge: true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${profile.roleLabel} • ${profile.semester}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.deepPrimary,
                    ),
                  ),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const ProfileTag('Active'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.domain_outlined, color: AppColors.deepPrimary),
                    SizedBox(width: 7),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Campus', style: TextStyle(fontSize: 9)),
                        Text(
                          'Sahiwal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 7),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SSO Status', style: TextStyle(fontSize: 9)),
                        Text(
                          'Authorized',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                          ),
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

  Widget _settingsGroup({
    required String title,
    required String subtitle,
    required List<Widget> rows,
  }) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
      ProfileCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              rows[index],
              if (index != rows.length - 1)
                const Divider(height: 1, color: AppColors.paleBlue),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _settingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String detail,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDanger = false,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDanger ? const Color(0xFFFFE4E4) : AppColors.lightBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: isDanger ? AppColors.error : AppColors.deepPrimary,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDanger ? AppColors.error : AppColors.primaryText,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              const Icon(Icons.chevron_right, color: AppColors.secondaryText),
        ],
      ),
    ),
  );

  void _feedback(String label, bool enabled) {
    showProfileMessage(
      context,
      '$label ${enabled ? 'enabled' : 'disabled'} for this preview.',
    );
  }
}
