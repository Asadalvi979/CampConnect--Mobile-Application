import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/admin_route_arguments.dart';
import '../models/admin_user.dart';
import '../services/admin_user_store.dart';
import '../widgets/admin_panel_layout.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String? _roleFilter;
  AdminAccountStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AdminPanelLayout(
    title: 'User Management',
    section: AdminPanelSection.users,
    child: AnimatedBuilder(
      animation: AdminUserStore.instance,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final users = AdminUserStore.instance.findUsers(
            query: _searchController.text,
            role: _roleFilter,
            status: _statusFilter,
          );
          final desktopTable = constraints.maxWidth >= 740;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      desktopTable ? 28 : 16,
                      18,
                      desktopTable ? 28 : 16,
                      12,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search name, email, or CMS ID',
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
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _roleChip('All roles', null),
                            _roleChip('Student', UserProfileRole.student.name),
                            _roleChip('Senior', UserProfileRole.senior.name),
                            _roleChip('Alumni', UserProfileRole.alumni.name),
                            SizedBox(
                              width: 190,
                              child:
                                  DropdownButtonFormField<AdminAccountStatus?>(
                                    initialValue: _statusFilter,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Account status',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text('All statuses'),
                                      ),
                                      DropdownMenuItem(
                                        value: AdminAccountStatus.active,
                                        child: Text('Active'),
                                      ),
                                      DropdownMenuItem(
                                        value: AdminAccountStatus.suspended,
                                        child: Text('Suspended'),
                                      ),
                                    ],
                                    onChanged: (value) =>
                                        setState(() => _statusFilter = value),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktopTable ? 28 : 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${users.length} ${users.length == 1 ? 'account' : 'accounts'}',
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: users.isEmpty
                        ? const _EmptyUsers()
                        : desktopTable
                        ? _UserTable(users: users)
                        : _UserCards(users: users),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _roleChip(String label, String? role) {
    final selected = _roleFilter == role;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _roleFilter = role),
      selectedColor: AppColors.lightBlue,
      labelStyle: TextStyle(
        color: selected ? AppColors.deepPrimary : AppColors.secondaryText,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}

class _UserTable extends StatelessWidget {
  const _UserTable({required this.users});

  final List<AdminUser> users;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
    child: Card(
      margin: EdgeInsets.zero,
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('USER')),
            DataColumn(label: Text('CMS ID')),
            DataColumn(label: Text('ROLE')),
            DataColumn(label: Text('EMAIL')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final user in users)
              DataRow(
                onSelectChanged: (_) => _openUser(context, user),
                cells: [
                  DataCell(
                    SizedBox(
                      width: 160,
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(Text(user.cmsId)),
                  DataCell(Text(_roleLabel(user.role))),
                  DataCell(
                    SizedBox(
                      width: 230,
                      child: Text(user.email, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  DataCell(_StatusBadge(status: user.accountStatus)),
                  DataCell(
                    IconButton(
                      tooltip: 'View account details',
                      onPressed: () => _openUser(context, user),
                      icon: const Icon(Icons.arrow_forward_ios, size: 15),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class _UserCards extends StatelessWidget {
  const _UserCards({required this.users});

  final List<AdminUser> users;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
    itemCount: users.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final user = users[index];
      return Card(
        margin: EdgeInsets.zero,
        color: AppColors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: CircleAvatar(
            backgroundColor: AppColors.paleBlue,
            child: Text(
              user.name[0],
              style: const TextStyle(
                color: AppColors.deepPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: [
                    Text(
                      '${_roleLabel(user.role)} · ${user.cmsId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedText,
                      ),
                    ),
                    _StatusBadge(status: user.accountStatus),
                  ],
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openUser(context, user),
        ),
      );
    },
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AdminAccountStatus status;

  @override
  Widget build(BuildContext context) {
    final active = status == AdminAccountStatus.active;
    final color = active ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Suspended',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyUsers extends StatelessWidget {
  const _EmptyUsers();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 44,
            color: AppColors.mutedText,
          ),
          const SizedBox(height: 12),
          const Text(
            'No accounts match your filters',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different search or filter.',
            style: TextStyle(color: AppColors.mutedText),
          ),
        ],
      ),
    ),
  );
}

String _roleLabel(UserProfileRole role) => switch (role) {
  UserProfileRole.student => 'Student',
  UserProfileRole.senior => 'Senior',
  UserProfileRole.alumni => 'Alumni',
  UserProfileRole.admin => 'Admin',
};

void _openUser(BuildContext context, AdminUser user) {
  Navigator.of(context).pushNamed(
    AppRoutes.adminUserDetails,
    arguments: AdminRouteArguments(userId: user.id),
  );
}
