import 'package:camp_connect/features/admin_panel/screens/admin_dashboard_screen.dart';
import 'package:camp_connect/features/authentication/screens/admin_login_preview_screen.dart';
import 'package:camp_connect/features/authentication/screens/login_screen.dart';
import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
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
    UserProfileStore.instance.setRole(UserProfileRole.student);
  });

  testWidgets('login screen provides a separate Admin preview entry point', (
    tester,
  ) async {
    await _pumpRoute(tester, route: AppRoutes.login);

    await tester.ensureVisible(find.text('Admin Login'));
    await tester.tap(find.text('Admin Login'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminLoginPreviewScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(
      UserProfileStore.instance.profile.value.role,
      UserProfileRole.student,
    );
  });

  testWidgets(
    'Admin preview validates required fields and rejects wrong credentials',
    (tester) async {
      await _pumpRoute(tester, route: AppRoutes.adminLogin);

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Enter the admin email.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);

      final inputs = find.byType(TextFormField);
      await tester.enterText(inputs.at(0), 'admin@campconnect.com');
      await tester.enterText(inputs.at(1), 'WrongPass');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
        find.text('Incorrect Admin preview email or password.'),
        findsOneWidget,
      );
      expect(
        UserProfileStore.instance.profile.value.role,
        UserProfileRole.student,
      );
      expect(find.byType(AdminDashboardScreen), findsNothing);
    },
  );

  testWidgets('valid preview credentials open Admin dashboard', (tester) async {
    await _pumpRoute(tester, route: AppRoutes.adminLogin);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@campconnect.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Admin123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(UserProfileStore.instance.profile.value.role, UserProfileRole.admin);
    expect(find.byType(AdminDashboardScreen), findsOneWidget);
  });

  testWidgets(
    'Admin can log out from mobile panel and return to preview login',
    (tester) async {
      await _pumpRoute(tester, route: AppRoutes.adminLogin);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'admin@campconnect.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Admin123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Log out of Admin preview'));
      await tester.pumpAndSettle();

      expect(
        UserProfileStore.instance.profile.value.role,
        UserProfileRole.student,
      );
      expect(find.byType(AdminLoginPreviewScreen), findsOneWidget);
      expect(find.byType(AdminDashboardScreen), findsNothing);
    },
  );

  testWidgets('Admin logout control is available in desktop panel', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.admin);
    await _pumpRoute(
      tester,
      route: AppRoutes.adminDashboard,
      size: const Size(1280, 900),
    );

    await tester.tap(find.byTooltip('Log out of Admin preview'));
    await tester.pumpAndSettle();

    expect(
      UserProfileStore.instance.profile.value.role,
      UserProfileRole.student,
    );
    expect(find.byType(AdminLoginPreviewScreen), findsOneWidget);
  });
}
