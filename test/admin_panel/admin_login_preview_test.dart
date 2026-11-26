import 'package:camp_connect/features/admin_panel/screens/admin_dashboard_screen.dart';
import 'package:camp_connect/features/authentication/models/registration_form_data.dart';
import 'package:camp_connect/features/authentication/screens/admin_login_preview_screen.dart';
import 'package:camp_connect/features/authentication/screens/login_screen.dart';
import 'package:camp_connect/features/authentication/services/auth_services.dart';
import 'package:camp_connect/features/authentication/services/authentication_service.dart';
import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// NOTE (Slice 1, Supabase): the old tests in this file asserted the deleted
/// hardcoded admin backdoor (admin@campconnect.com / Admin123). That
/// credential no longer exists: admin login now signs in via Supabase Auth
/// and requires profiles.role == admin. The tests below were rewritten for
/// the real flow — see the inline comments.

/// Fake auth service: sign-in always succeeds for any credentials.
class _FakeAdminAuthService implements AuthenticationService {
  @override
  String? get currentUserId => 'admin-user-id';

  @override
  String? get currentUserEmail => 'admin@campconnect.com';

  @override
  Future<void> requestLoginOtp(String email) async {}

  @override
  Future<void> register(RegistrationFormData registration) async {}

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String code,
    bool isLoginOtp = true,
  }) async {}

  @override
  Future<void> resendEmailOtp(String email) async {}

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}

const _fakeAdminProfile = UserProfile(
  id: 'admin-user-id',
  name: 'Admin',
  role: UserProfileRole.admin,
  program: 'BS Software Engineering (BSSE)',
  semester: '—',
  location: 'Sahiwal, Pakistan',
  bio: 'CampConnect administrator.',
  email: 'admin@campconnect.com',
  studentId: 'ADMIN-001',
  university: 'Riphah International University',
  department: 'Faculty of Computing & Information Technology',
  academicSession: '2024 – 2028',
  cgpa: '—',
  skills: [],
  interests: [],
);

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

  tearDown(() {
    // Restore the real service and profile loader after every test.
    AuthServices.reset();
    UserProfileStore.profileLoaderOverride = null;
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
    'Admin login validates required fields and reports Supabase not configured',
    (tester) async {
      // Supabase has no real keys in tests, so any sign-in attempt reports
      // that the backend is not configured instead of checking credentials.
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
        find.textContaining('Supabase is not configured yet'),
        findsOneWidget,
      );
      expect(
        UserProfileStore.instance.profile.value.role,
        UserProfileRole.student,
      );
      expect(find.byType(AdminDashboardScreen), findsNothing);
    },
  );

  testWidgets('admin account opens Admin dashboard via the auth service', (
    tester,
  ) async {
    // Fake Supabase auth + fake admin profile (the real flow, minus network).
    AuthServices.current = _FakeAdminAuthService();
    UserProfileStore.profileLoaderOverride = (_, _) async => _fakeAdminProfile;

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
    'non-admin account is refused Admin dashboard even after sign-in',
    (tester) async {
      AuthServices.current = _FakeAdminAuthService();
      // The signed-in user is a student, not an admin.
      UserProfileStore.profileLoaderOverride = (_, _) async =>
          _fakeAdminProfile.copyWith(role: UserProfileRole.student);

      await _pumpRoute(tester, route: AppRoutes.adminLogin);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'student@university.edu',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
        find.text('This account does not have admin access.'),
        findsOneWidget,
      );
      expect(find.byType(AdminDashboardScreen), findsNothing);
    },
  );

  testWidgets(
    'Admin can log out from mobile panel and return to preview login',
    (tester) async {
      UserProfileStore.instance.setRole(UserProfileRole.admin);
      await _pumpRoute(tester, route: AppRoutes.adminDashboard);

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
