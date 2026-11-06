import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/notifications_announcements/models/announcement.dart';
import 'package:camp_connect/features/notifications_announcements/screens/announcement_create_screen.dart';
import 'package:camp_connect/features/notifications_announcements/services/notification_announcement_store.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
import 'package:camp_connect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester, {required String route}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(CampConnectApp(initialRoute: route));
  await tester.pumpAndSettle();
}

void main() {
  final store = NotificationAnnouncementStore.instance;

  setUp(() {
    store.resetMockData();
    UserProfileStore.instance.setRole(UserProfileRole.student);
  });

  testWidgets('notifications filter and mark read update the shared count', (
    tester,
  ) async {
    await _pumpApp(tester, route: AppRoutes.notifications);
    expect(find.text('Message request'), findsOneWidget);
    expect(find.text('Unread (2)'), findsOneWidget);
    expect(store.unreadCountFor('current-student'), 2);

    await tester.tap(find.text('Message request'));
    await tester.pumpAndSettle();
    expect(store.unreadCountFor('current-student'), 1);
    expect(find.text('Unread (1)'), findsOneWidget);

    await tester.tap(find.text('Unread (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Mentorship'), findsOneWidget);
    expect(find.text('Message request'), findsNothing);
  });

  testWidgets('announcement details open from the published list', (
    tester,
  ) async {
    await _pumpApp(tester, route: AppRoutes.announcements);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Create Announcement'), findsNothing);
    await tester.tap(
      find.text('Fall 2024 Capstone Project & FYP Proposals Open'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Announcement Details'), findsOneWidget);
    expect(find.textContaining('supervisor approval letters'), findsOneWidget);
  });

  testWidgets('only admins can open the announcement creation form', (
    tester,
  ) async {
    await _pumpApp(tester, route: AppRoutes.announcementCreate);
    expect(find.byType(AnnouncementCreateScreen), findsOneWidget);
    expect(
      find.text('Admin access is required to create announcements.'),
      findsOneWidget,
    );
    expect(
      store.createAndPublishAnnouncement(
        role: UserProfileRole.student,
        adminId: 'current-student',
        title: 'Not allowed',
        content: 'This should not be published.',
      ),
      AnnouncementPublishResult.unauthorized,
    );
    expect(store.publishedAnnouncements(), hasLength(3));
  });

  testWidgets('admin can publish and create in-app mock notifications', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.admin);
    await _pumpApp(tester, route: AppRoutes.announcements);
    expect(find.text('Announcement Management'), findsOneWidget);
    await tester.tap(find.byTooltip('Create announcement'));
    await tester.pumpAndSettle();
    expect(find.text('Publish Announcement'), findsOneWidget);
    await tester.ensureVisible(find.text('Publish Announcement'));
    await tester.tap(find.text('Publish Announcement'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an announcement title.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Local test announcement',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Published only to this in-memory preview.',
    );
    await tester.ensureVisible(find.text('Publish Announcement'));
    await tester.tap(find.text('Publish Announcement'));
    await tester.pumpAndSettle();

    final created = store.announcements.singleWhere(
      (announcement) => announcement.title == 'Local test announcement',
    );
    expect(created.status, AnnouncementStatus.published);
    expect(store.publishedAnnouncements(), hasLength(4));
    expect(store.unreadCountFor('current-student'), 3);
    expect(store.unreadCountFor('current-senior'), 2);
    expect(store.unreadCountFor('mentor-bilal'), 2);
    expect(find.text('Local test announcement'), findsOneWidget);
  });

  testWidgets('dashboard shortcuts open notifications and announcements', (
    tester,
  ) async {
    await _pumpApp(tester, route: AppRoutes.studentDashboard);
    await tester.tap(find.byTooltip('Notifications: 2 unread'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    await tester.tap(find.text('Message request'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Notifications: 1 unread'), findsOneWidget);

    await tester.ensureVisible(find.text('View Notice  →'));
    await tester.tap(find.text('View Notice  →'));
    await tester.pumpAndSettle();
    expect(find.text('Announcements'), findsOneWidget);
  });

  testWidgets('senior and alumni dashboards open notifications and notices', (
    tester,
  ) async {
    for (final (role, route, unreadCount) in [
      (UserProfileRole.senior, AppRoutes.seniorDashboard, 1),
      (UserProfileRole.alumni, AppRoutes.alumniDashboard, 1),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      UserProfileStore.instance.setRole(role);
      await _pumpApp(tester, route: route);
      expect(
        find.byTooltip('Notifications: $unreadCount unread'),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('View Notice'));
      await tester.tap(find.text('View Notice').last);
      await tester.pumpAndSettle();
      expect(find.text('Announcements'), findsOneWidget);
      expect(find.text('Create Announcement'), findsNothing);
    }
  });
}
