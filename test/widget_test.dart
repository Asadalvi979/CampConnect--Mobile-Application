import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camp_connect/features/authentication/models/otp_screen_arguments.dart';
import 'package:camp_connect/features/home_dashboard/models/dashboard_role.dart';
import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
import 'package:camp_connect/main.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  String initialRoute = AppRoutes.splash,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(CampConnectApp(initialRoute: initialRoute));
}

void main() {
  testWidgets('splash advances to login', (tester) async {
    await _pumpApp(tester);

    expect(find.text('CampConnect'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('login validates email/password and toggles password', (
    tester,
  ) async {
    await _pumpApp(tester, initialRoute: AppRoutes.login);

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your university email.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'bad-email');
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'student@university.edu',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isFalse,
    );
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Verify Your Email'), findsOneWidget);
    expect(find.text('s***t@university.edu'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Verify Email'));
    await tester.tap(find.text('Verify Email'));
    await tester.pumpAndSettle();
    expect(find.text('Student Home Dashboard'), findsOneWidget);
  });

  testWidgets('login opens forgot password and returns to login', (
    tester,
  ) async {
    await _pumpApp(tester, initialRoute: AppRoutes.login);

    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.text('Registered Email'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'student@university.edu',
    );
    await tester.ensureVisible(find.text('Send Reset Instructions'));
    await tester.tap(find.text('Send Reset Instructions'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Preview only. No reset email was sent; password recovery needs backend integration.',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Back to Login'));
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets(
    'registration validates then previews email OTP and returns login',
    (tester) async {
      await _pumpApp(tester, initialRoute: AppRoutes.register);

      await tester.ensureVisible(find.text('Continue to Verification'));
      await tester.tap(find.text('Continue to Verification'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your full name.'), findsOneWidget);

      final inputs = find.byType(TextFormField);
      const values = [
        'Ali Raza',
        'F24-BSSE-0044',
        'student@university.edu',
        'securepass123',
        'securepass123',
      ];
      for (var index = 0; index < values.length; index++) {
        await tester.ensureVisible(inputs.at(index));
        await tester.enterText(inputs.at(index), values[index]);
      }

      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.ensureVisible(find.text('Continue to Verification'));
      await tester.tap(find.text('Continue to Verification'));
      await tester.pumpAndSettle();

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('s***t@university.edu'), findsOneWidget);
      await tester.ensureVisible(find.text('492718'));
      await tester.tap(find.text('492718'));
      await tester.pumpAndSettle();
      expect(find.text('Verify Your Email'), findsOneWidget);
      await tester.ensureVisible(find.text('Verify Email'));
      await tester.tap(find.text('Verify Email'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(
        find.text(
          'Preview only: this code has not been verified. Backend integration is required.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('OTP route displays the supplied university email', (
    tester,
  ) async {
    await _pumpApp(tester, initialRoute: AppRoutes.login);
    Navigator.of(tester.element(find.text('Welcome Back!'))).pushNamed(
      AppRoutes.verifyEmail,
      arguments: const OtpScreenArguments(email: 'student@university.edu'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Verify Your Email'), findsOneWidget);
  });

  testWidgets('student dashboard shows student-specific content', (
    tester,
  ) async {
    expect(
      AppRoutes.dashboardRouteFor(DashboardRole.student),
      AppRoutes.studentDashboard,
    );
    await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);

    expect(find.text('Student Home Dashboard'), findsOneWidget);
    expect(find.text('Campus Services'), findsOneWidget);
    expect(find.text('Available Mentors'), findsOneWidget);
    expect(find.text('Verified Resources'), findsOneWidget);
  });

  testWidgets('senior dashboard offers alumni mentor discovery', (
    tester,
  ) async {
    expect(
      AppRoutes.dashboardRouteFor(DashboardRole.senior),
      AppRoutes.seniorDashboard,
    );
    await _pumpApp(tester, initialRoute: AppRoutes.seniorDashboard);

    expect(find.text('Senior Home Dashboard'), findsOneWidget);
    expect(find.text('Senior Actions'), findsOneWidget);
    expect(find.text('Find an Alumni Mentor'), findsOneWidget);
    expect(find.text('Capstone Opportunities'), findsOneWidget);
  });

  testWidgets('alumni dashboard shows alumni mentorship content', (
    tester,
  ) async {
    expect(
      AppRoutes.dashboardRouteFor(DashboardRole.alumni),
      AppRoutes.alumniDashboard,
    );
    await _pumpApp(tester, initialRoute: AppRoutes.alumniDashboard);

    expect(find.text('Alumni Home Dashboard'), findsOneWidget);
    expect(find.text('Quick Navigation'), findsOneWidget);
    expect(find.text('Active Mentorships'), findsOneWidget);
    expect(find.text('Industry Advisory Board'), findsOneWidget);
  });

  testWidgets('project dashboard shortcut opens discovery', (tester) async {
    await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);

    await tester.tap(find.text('Projects').first);
    await tester.pumpAndSettle();

    expect(find.text('Project List'), findsOneWidget);
  });

  testWidgets('Campus Services shows redesigned service tiles', (tester) async {
    await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);

    expect(find.text('Campus Services'), findsOneWidget);
    expect(find.text('Everything you need, all in one place'), findsOneWidget);
    expect(find.text('6 services'), findsOneWidget);
    expect(find.text('Find your people'), findsOneWidget);
    expect(find.text('Build together'), findsOneWidget);
    expect(find.text('Chat with peers'), findsOneWidget);

    await tester.tap(find.text('Build together'));
    await tester.pumpAndSettle();
    expect(find.text('Project List'), findsOneWidget);
  });

  testWidgets('community bottom navigation opens Projects and Messages', (
    tester,
  ) async {
    await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);

    await tester.tap(find.text('Community').last);
    await tester.pumpAndSettle();
    expect(find.text('Communities'), findsOneWidget);

    await tester.tap(find.text('Projects').last);
    await tester.pumpAndSettle();
    expect(find.text('Project List'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Communities'), findsOneWidget);

    await tester.tap(find.text('Messages').last);
    await tester.pumpAndSettle();
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Zainab Farooq'), findsOneWidget);
  });

  testWidgets('dashboard opens profile and local edits update My Profile', (
    tester,
  ) async {
    UserProfileStore.instance.update(
      UserProfileStore.instance.profile.value.copyWith(
        name: 'Asadullah Sadiq',
        role: UserProfileRole.student,
      ),
    );
    await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('User Profile'), findsOneWidget);

    await tester.tap(find.text('Edit Profile').first);
    await tester.pumpAndSettle();
    expect(find.text('Personal Information'), findsOneWidget);

    final nameField = find.byType(TextFormField).first;
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, '');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('Enter your full name.'), findsOneWidget);

    await tester.enterText(nameField, 'Ayesha Sadiq');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('Ayesha Sadiq'), findsOneWidget);
    expect(find.text('Profile changes saved locally.'), findsOneWidget);
  });

  testWidgets('profile settings toggles locally and returns to My Profile', (
    tester,
  ) async {
    await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profile Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    final appSwitch = find.byType(Switch).first;
    expect(tester.widget<Switch>(appSwitch).value, isTrue);
    await tester.ensureVisible(appSwitch);
    await tester.tap(appSwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(appSwitch).value, isFalse);
    expect(
      find.text('App notifications disabled for this preview.'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('User Profile'), findsOneWidget);
  });

  testWidgets('logging out from settings returns to login and clears role', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.alumni);
    await _pumpApp(tester, initialRoute: AppRoutes.profileSettings);

    await tester.dragUntilVisible(
      find.text('Log Out'),
      find.byType(ListView),
      const Offset(0, -450),
    );
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(
      UserProfileStore.instance.profile.value.role,
      UserProfileRole.student,
    );
  });

  testWidgets('selecting a project opens public profile and back returns', (
    tester,
  ) async {
    await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('CampConnect Mobile App'),
      find.byType(ListView),
      const Offset(0, -350),
    );
    await tester.tap(find.text('CampConnect Mobile App'));
    await tester.pumpAndSettle();
    expect(find.text('Zainab Fatima'), findsOneWidget);
    expect(find.text('Find Alumni Mentor'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('User Profile'), findsOneWidget);
  });

  testWidgets('senior dashboard opens the shared student profile structure', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.senior);
    await _pumpApp(tester, initialRoute: AppRoutes.seniorDashboard);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Senior'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Education'),
      find.byType(ListView),
      const Offset(0, -350),
    );
    expect(find.text('Education'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Skills'),
      find.byType(ListView),
      const Offset(0, -350),
    );
    expect(find.text('Skills'), findsOneWidget);
  });

  testWidgets(
    'community navigation creates, likes, comments on, and edits own posts',
    (tester) async {
      await _pumpApp(tester, initialRoute: AppRoutes.studentDashboard);

      await tester.tap(find.text('Community').last);
      await tester.pumpAndSettle();
      expect(find.text('Communities'), findsOneWidget);
      expect(find.text('Explore Communities'), findsOneWidget);

      await tester.tap(find.text('Software Engineering Community').first);
      await tester.pumpAndSettle();
      expect(find.text('Community Details'), findsOneWidget);

      await tester.ensureVisible(find.textContaining('Members ('));
      await tester.tap(find.textContaining('Members ('));
      await tester.pumpAndSettle();
      expect(find.text('Community Members'), findsOneWidget);
      expect(find.text('Zainab Fatima'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Community Details'), findsOneWidget);

      await tester.ensureVisible(find.text('Create Post'));
      await tester.tap(find.text('Create Post').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Posting in Software Engineering Community'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Publish').last);
      await tester.tap(find.text('Publish').last);
      await tester.pumpAndSettle();
      expect(find.text('Write something before publishing.'), findsOneWidget);

      const postContent =
          'Looking for teammates to build a campus study planner.';
      await tester.enterText(find.byType(TextFormField), postContent);
      await tester.ensureVisible(find.text('Publish').last);
      await tester.tap(find.text('Publish').last);
      await tester.pumpAndSettle();
      expect(find.text('Community Details'), findsOneWidget);
      expect(find.text(postContent), findsOneWidget);

      await tester.tap(find.text(postContent));
      await tester.pumpAndSettle();
      expect(find.text('Post Details'), findsOneWidget);
      expect(find.text('0 Likes'), findsOneWidget);

      await tester.tap(find.text('Like'));
      await tester.pumpAndSettle();
      expect(find.text('1 Likes'), findsOneWidget);
      await tester.tap(find.text('Liked'));
      await tester.pumpAndSettle();
      expect(find.text('0 Likes'), findsOneWidget);
      await tester.tap(find.text('Like'));
      await tester.pumpAndSettle();
      expect(find.text('1 Likes'), findsOneWidget);
      await tester.tap(find.text('Comment'));
      await tester.pumpAndSettle();
      expect(find.text('Comments Screen'), findsOneWidget);

      await tester.ensureVisible(find.byTooltip('Send comment'));
      await tester.tap(find.byTooltip('Send comment'));
      await tester.pumpAndSettle();
      expect(find.text('Write a comment before sending.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).last,
        'I can help with the planner UI.',
      );
      await tester.ensureVisible(find.byTooltip('Send comment'));
      await tester.tap(find.byTooltip('Send comment'));
      await tester.pumpAndSettle();
      expect(find.text('I can help with the planner UI.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('1 Comments'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit Post'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Post'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField),
        'Updated campus study planner discussion.',
      );
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(
        find.text('Updated campus study planner discussion.'),
        findsOneWidget,
      );
    },
  );
}
