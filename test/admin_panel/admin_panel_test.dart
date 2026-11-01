import 'package:camp_connect/features/admin_panel/models/admin_user.dart';
import 'package:camp_connect/features/admin_panel/screens/admin_dashboard_screen.dart';
import 'package:camp_connect/features/admin_panel/screens/admin_user_details_screen.dart';
import 'package:camp_connect/features/admin_panel/screens/admin_users_screen.dart';
import 'package:camp_connect/features/admin_panel/services/admin_user_store.dart';
import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/notifications_announcements/screens/announcement_create_screen.dart';
import 'package:camp_connect/features/notifications_announcements/screens/announcement_details_screen.dart';
import 'package:camp_connect/features/notifications_announcements/screens/announcement_list_screen.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
import 'package:camp_connect/features/resources/screens/resource_moderation_details_screen.dart';
import 'package:camp_connect/features/resources/screens/resource_moderation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpRoute(
  WidgetTester tester, {
  required String route,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      initialRoute: route,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onGenerateInitialRoutes: (initialRoute) => [
        AppRoutes.onGenerateRoute(RouteSettings(name: initialRoute)),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AdminUserStore.instance.resetMockData();
    UserProfileStore.instance.setRole(UserProfileRole.admin);
  });

  testWidgets('dashboard adapts to desktop and mobile layouts', (tester) async {
    await _pumpRoute(
      tester,
      route: AppRoutes.adminDashboard,
      size: const Size(1280, 900),
    );
    expect(find.text('WORKSPACE'), findsOneWidget);
    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Mock users'), findsOneWidget);
    final desktopException = tester.takeException();
    expect(
      desktopException,
      isNull,
      reason: desktopException is FlutterError
          ? desktopException.toStringDeep()
          : '$desktopException',
    );

    await _pumpRoute(tester, route: AppRoutes.adminDashboard);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.text(
        'All figures and actions are local mock previews, not live university data.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-admin role cannot open the Admin dashboard', (tester) async {
    UserProfileStore.instance.setRole(UserProfileRole.student);
    await _pumpRoute(tester, route: AppRoutes.adminDashboard);

    expect(find.text('Administrator access required'), findsOneWidget);
    expect(find.text('Management'), findsNothing);
  });

  testWidgets('resource moderation integration checks the active role', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.adminDashboard);
    UserProfileStore.instance.setRole(UserProfileRole.student);

    await tester.ensureVisible(find.text('Resource Moderation'));
    await tester.tap(find.text('Resource Moderation'));
    await tester.pumpAndSettle();

    expect(find.byType(ResourceModerationScreen), findsOneWidget);
    expect(find.text('Administrator access required'), findsOneWidget);
  });

  testWidgets('user search filters mock accounts by name', (tester) async {
    await _pumpRoute(tester, route: AppRoutes.adminUsers);

    expect(find.text('Areeba Khan'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Zainab');
    await tester.pumpAndSettle();

    expect(find.text('Zainab Farooq'), findsOneWidget);
    expect(find.text('Areeba Khan'), findsNothing);
  });

  testWidgets('user list supports role and account status filters', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.adminUsers);

    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();
    expect(find.text('Zainab Farooq'), findsNothing);
    expect(find.text('Areeba Khan'), findsOneWidget);

    await tester.tap(find.text('All roles'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<AdminAccountStatus?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suspended').last);
    await tester.pumpAndSettle();

    expect(find.text('Hamza Tariq'), findsOneWidget);
    expect(find.text('Areeba Khan'), findsNothing);
  });

  testWidgets('desktop user management displays the table layout', (
    tester,
  ) async {
    await _pumpRoute(
      tester,
      route: AppRoutes.adminUsers,
      size: const Size(1280, 900),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Areeba Khan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('user details back navigation returns to the user list', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.adminUsers);

    await tester.tap(find.text('Areeba Khan'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminUserDetailsScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AdminUsersScreen), findsOneWidget);
    expect(find.text('Areeba Khan'), findsOneWidget);
  });

  testWidgets('Admin can suspend and reactivate a user in memory', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.adminUsers);

    await tester.tap(find.text('Areeba Khan'));
    await tester.pumpAndSettle();
    expect(find.text('Account information'), findsOneWidget);
    expect(find.text('Suspend account'), findsOneWidget);

    await tester.ensureVisible(find.text('Suspend account'));
    await tester.tap(find.text('Suspend account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Suspend'));
    await tester.pumpAndSettle();

    expect(
      AdminUserStore.instance.userById('mock-user-001')!.accountStatus,
      AdminAccountStatus.suspended,
    );
    expect(find.text('Reactivate account'), findsOneWidget);

    await tester.ensureVisible(find.text('Reactivate account'));
    await tester.tap(find.text('Reactivate account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reactivate'));
    await tester.pumpAndSettle();

    expect(
      AdminUserStore.instance.userById('mock-user-001')!.accountStatus,
      AdminAccountStatus.active,
    );
  });

  testWidgets(
    'announcement list, details, and create routes return correctly',
    (tester) async {
      await _pumpRoute(tester, route: AppRoutes.adminDashboard);

      await tester.ensureVisible(find.text('Announcement Management'));
      await tester.tap(find.text('Announcement Management'));
      await tester.pumpAndSettle();
      expect(find.byType(AnnouncementListScreen), findsOneWidget);
      expect(find.text('Published campus announcements'), findsOneWidget);

      await tester.tap(
        find.text('Fall 2024 Capstone Project & FYP Proposals Open'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnnouncementDetailsScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(AnnouncementListScreen), findsOneWidget);

      await tester.tap(find.text('New Announcement'));
      await tester.pumpAndSettle();
      expect(find.byType(AnnouncementCreateScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(AnnouncementListScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(AdminDashboardScreen), findsOneWidget);
    },
  );

  testWidgets('Admin bottom bar remains connected across linked pages', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.adminDashboard);

    await tester.tap(find.text('Resources'));
    await tester.pumpAndSettle();
    expect(find.byType(ResourceModerationScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(find.byType(AnnouncementListScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(
      find.text('Fall 2024 Capstone Project & FYP Proposals Open'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AnnouncementDetailsScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminUsersScreen), findsOneWidget);
    expect(find.byType(AnnouncementListScreen), findsNothing);
    expect(find.byType(AnnouncementDetailsScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('moderation report details return to the report queue', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.adminDashboard);
    await tester.ensureVisible(find.text('Resource Moderation'));
    await tester.tap(find.text('Resource Moderation'));
    await tester.pumpAndSettle();
    expect(find.byType(ResourceModerationScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(
      find.text('Numerical Analysis Textbook Unofficial Edition'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ResourceModerationDetailsScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ResourceModerationScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets(
    'mobile navigation switches sections without stacking duplicates',
    (tester) async {
      await _pumpRoute(tester, route: AppRoutes.adminDashboard);

      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminUsersScreen), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.byType(AdminUsersScreen), findsNothing);

      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminUsersScreen), findsOneWidget);
      expect(find.byType(AdminDashboardScreen), findsNothing);
    },
  );

  testWidgets('dashboard links to existing resource moderation screen', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.adminDashboard);
    await tester.ensureVisible(find.text('Resource Moderation'));
    await tester.tap(find.text('Resource Moderation'));
    await tester.pumpAndSettle();
    expect(find.byType(ResourceModerationScreen), findsOneWidget);
  });
}
