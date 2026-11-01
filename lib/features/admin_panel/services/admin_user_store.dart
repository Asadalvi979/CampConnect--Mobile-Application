import 'package:flutter/foundation.dart';

import '../data/admin_mock_data.dart';
import '../models/admin_user.dart';

enum AdminUserUpdateResult { updated, unavailable, unchanged }

class AdminUserStore extends ChangeNotifier {
  AdminUserStore._()
    : _users = List.of(AdminMockData.users),
      _activity = List.of(AdminMockData.initialActivity);

  static final AdminUserStore instance = AdminUserStore._();

  final List<AdminUser> _users;
  final List<AdminActivity> _activity;

  List<AdminUser> get users => List.unmodifiable(_users);
  List<AdminActivity> get activity => _activity.toList()
    ..sort((first, second) => second.occurredAt.compareTo(first.occurredAt));

  void resetMockData() {
    _users
      ..clear()
      ..addAll(AdminMockData.users);
    _activity
      ..clear()
      ..addAll(AdminMockData.initialActivity);
    notifyListeners();
  }

  AdminUser? userById(String id) {
    for (final user in _users) {
      if (user.id == id) return user;
    }
    return null;
  }

  List<AdminUser> findUsers({
    String query = '',
    String? role,
    AdminAccountStatus? status,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return _users.where((user) {
      final matchesRole = role == null || user.role.name == role;
      final matchesStatus = status == null || user.accountStatus == status;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          user.name.toLowerCase().contains(normalizedQuery) ||
          user.email.toLowerCase().contains(normalizedQuery) ||
          user.cmsId.toLowerCase().contains(normalizedQuery);
      return matchesRole && matchesStatus && matchesQuery;
    }).toList()..sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
  }

  AdminUserUpdateResult setAccountStatus({
    required String userId,
    required AdminAccountStatus status,
  }) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index < 0) return AdminUserUpdateResult.unavailable;
    final user = _users[index];
    if (user.accountStatus == status) return AdminUserUpdateResult.unchanged;
    _users[index] = user.copyWith(accountStatus: status);
    _activity.add(
      AdminActivity(
        description:
            'Account ${status == AdminAccountStatus.suspended ? 'suspended' : 'reactivated'}',
        context: '${user.name} · ${user.cmsId}',
        occurredAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return AdminUserUpdateResult.updated;
  }
}
