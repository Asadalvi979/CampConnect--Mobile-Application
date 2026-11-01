import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../models/admin_route_arguments.dart';
import '../models/admin_user.dart';
import '../services/admin_user_store.dart';
import '../widgets/admin_panel_layout.dart';

class AdminUserDetailsScreen extends StatelessWidget {
  const AdminUserDetailsScreen({required this.arguments, super.key});

  final AdminRouteArguments arguments;

  @override
  Widget build(BuildContext context) => AdminPanelLayout(
    title: 'User Details',
    section: AdminPanelSection.users,
    showBackButton: true,
    child: AnimatedBuilder(
      animation: AdminUserStore.instance,
      builder: (context, _) {
        final id = arguments.userId;
        final user = id == null ? null : AdminUserStore.instance.userById(id);
        if (user == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'This mock account is unavailable.',
                style: TextStyle(color: AppColors.mutedText),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 750;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                wide ? 30 : 16,
                20,
                wide ? 30 : 16,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.paleBlue,
                                child: Text(
                                  user.name[0],
                                  style: const TextStyle(
                                    color: AppColors.deepPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      user.email,
                                      style: const TextStyle(
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    _StatusBadge(status: user.accountStatus),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      const Text(
                        'Account information',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        margin: EdgeInsets.zero,
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: LayoutBuilder(
                            builder: (context, cardConstraints) {
                              final infoWidth = cardConstraints.maxWidth >= 700
                                  ? 300.0
                                  : cardConstraints.maxWidth;
                              return Wrap(
                                spacing: 24,
                                runSpacing: 18,
                                children: [
                                  _InfoField(
                                    width: infoWidth,
                                    label: 'CMS ID',
                                    value: user.cmsId,
                                  ),
                                  _InfoField(
                                    width: infoWidth,
                                    label: 'Role',
                                    value: _roleLabel(user.role),
                                  ),
                                  _InfoField(
                                    width: infoWidth,
                                    label: 'Program',
                                    value: user.program,
                                  ),
                                  _InfoField(
                                    width: infoWidth,
                                    label: 'Department',
                                    value: user.department,
                                  ),
                                  _InfoField(
                                    width: infoWidth,
                                    label: 'Joined',
                                    value:
                                        '${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}',
                                  ),
                                  _InfoField(
                                    width: infoWidth,
                                    label: 'Account status',
                                    value: _statusLabel(user.accountStatus),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      _ActionCard(user: user),
                      const SizedBox(height: 12),
                      const Text(
                        'This action updates only the temporary local preview. It does not revoke sessions or change server access.',
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final isActive = user.accountStatus == AdminAccountStatus.active;
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account action',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              isActive
                  ? 'Suspend this account in the local preview.'
                  : 'Reactivate this account in the local preview.',
              style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmAccountAction(context, isActive),
                icon: Icon(
                  isActive
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                ),
                label: Text(
                  isActive ? 'Suspend account' : 'Reactivate account',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isActive
                      ? AppColors.error
                      : AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAccountAction(BuildContext context, bool suspend) async {
    final action = suspend ? 'suspend' : 'reactivate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${suspend ? 'Suspend' : 'Reactivate'} account?'),
        content: Text(
          'This changes ${user.name}’s status in the temporary local preview only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(suspend ? 'Suspend' : 'Reactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = AdminUserStore.instance.setAccountStatus(
      userId: user.id,
      status: suspend
          ? AdminAccountStatus.suspended
          : AdminAccountStatus.active,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result == AdminUserUpdateResult.updated
                ? 'Account $action in the local preview.'
                : 'The account could not be updated.',
          ),
        ),
      );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AdminAccountStatus status;

  @override
  Widget build(BuildContext context) {
    final active = status == AdminAccountStatus.active;
    final color = active ? AppColors.success : AppColors.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          _statusLabel(status),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _statusLabel(AdminAccountStatus status) => switch (status) {
  AdminAccountStatus.active => 'Active',
  AdminAccountStatus.suspended => 'Suspended',
};

String _roleLabel(UserProfileRole role) => switch (role) {
  UserProfileRole.student => 'Student',
  UserProfileRole.senior => 'Senior',
  UserProfileRole.alumni => 'Alumni',
  UserProfileRole.admin => 'Admin',
};
