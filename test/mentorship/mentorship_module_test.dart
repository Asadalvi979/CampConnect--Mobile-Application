import 'package:camp_connect/features/mentorship/models/mentorship_request.dart';
import 'package:camp_connect/features/mentorship/services/mentorship_store.dart';
import 'package:camp_connect/features/navigation/app_routes.dart';
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
}

void main() {
  testWidgets('student can search alumni, validate and send a request', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.student);
    await _pumpApp(tester, route: AppRoutes.studentDashboard);

    await tester.ensureVisible(find.text('Find Mentors'));
    await tester.tap(find.text('Find Mentors'));
    await tester.pumpAndSettle();
    expect(find.text('Alumni Directory'), findsOneWidget);

    await tester.tap(find.byTooltip('Filter alumni'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cloud Computing').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(find.text('Hamza Raza'), findsOneWidget);
    expect(find.text('Bilal Ahmed'), findsNothing);
    await tester.tap(find.byTooltip('Filter alumni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hamza');
    await tester.pumpAndSettle();
    expect(find.text('Hamza Raza'), findsOneWidget);
    expect(find.text('Bilal Ahmed'), findsNothing);

    await tester.ensureVisible(find.text('View profile'));
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();
    expect(find.text('Alumni Profile'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Request mentorship'),
      find.byType(ListView).last,
      const Offset(0, -350),
    );
    await tester.tap(find.text('Request mentorship'));
    await tester.pumpAndSettle();
    expect(find.text('Request Mentorship'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Send request'),
      find.byType(ListView).last,
      const Offset(0, -350),
    );
    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();
    expect(find.text('Select an area'), findsOneWidget);
    expect(find.text('Select a cadence'), findsOneWidget);
    expect(find.text('Add a short personal message'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cloud Computing').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monthly').last);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byType(TextFormField),
      find.byType(ListView).last,
      const Offset(0, -350),
    );
    await tester.enterText(
      find.byType(TextFormField),
      'I would value your advice on preparing for cloud engineering roles.',
    );
    await tester.dragUntilVisible(
      find.text('Send request'),
      find.byType(ListView).last,
      const Offset(0, -350),
    );
    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    final request = MentorshipStore.instance
        .sentRequests('current-student')
        .firstWhere((item) => item.alumniId == 'mentor-hamza');
    expect(request.status, MentorshipRequestStatus.pending);
    expect(
      MentorshipStore.instance.createRequest(
        requesterRole: UserProfileRole.student,
        requesterId: 'current-student',
        alumniId: 'mentor-hamza',
        focusArea: 'Cloud Computing',
        cadence: 'Monthly',
        message: 'A second pending request must not be created.',
      ),
      RequestCreationResult.duplicate,
    );
    await tester.dragUntilVisible(
      find.text('View pending request'),
      find.byType(ListView).last,
      const Offset(0, -350),
    );
    expect(find.text('View pending request'), findsOneWidget);
  });

  testWidgets('alumni can review a pending request and activate mentorship', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.alumni);
    await _pumpApp(tester, route: AppRoutes.alumniDashboard);

    await tester.tap(find.text('Requests').first);
    await tester.pumpAndSettle();
    expect(find.text('Mentorship Requests'), findsOneWidget);
    expect(find.text('Incoming'), findsOneWidget);
    expect(find.text('Usman Ali'), findsOneWidget);

    await tester.tap(find.text('Details').first);
    await tester.pumpAndSettle();
    expect(find.text('Request Details'), findsOneWidget);
    expect(find.text('Accept request'), findsOneWidget);
    await tester.tap(find.text('Accept request'));
    await tester.pumpAndSettle();

    final store = MentorshipStore.instance;
    expect(
      store.requestById('request-incoming-usman')?.status,
      MentorshipRequestStatus.accepted,
    );
    expect(
      store.mentorships.any(
        (relationship) => relationship.requestId == 'request-incoming-usman',
      ),
      isTrue,
    );
    expect(
      store
          .activeMentorshipsFor('mentor-bilal')
          .any(
            (relationship) =>
                relationship.requestId == 'request-incoming-usman',
          ),
      isTrue,
    );

    await tester.tap(find.byTooltip('Active mentorships'));
    await tester.pumpAndSettle();
    expect(find.text('Active Mentorships'), findsOneWidget);
    expect(find.text('Usman Ali'), findsOneWidget);
    await tester.tap(find.text('Message').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Hey! How is your semester project going?'),
      findsOneWidget,
    );
  });

  test(
    'only alumni can decide requests; rejection creates no active relation',
    () {
      final store = MentorshipStore.instance;
      final relationshipsBefore = store.mentorships.length;
      final rejected = store.rejectRequest(
        requestId: 'request-incoming-daniyal',
        viewerRole: UserProfileRole.alumni,
        viewerId: 'mentor-bilal',
      );
      expect(rejected, isTrue);
      expect(
        store.requestById('request-incoming-daniyal')?.status,
        MentorshipRequestStatus.rejected,
      );
      expect(
        store.mentorships.any(
          (relationship) =>
              relationship.requestId == 'request-incoming-daniyal',
        ),
        isFalse,
      );
      expect(store.mentorships.length, relationshipsBefore);

      expect(
        store.acceptRequest(
          requestId: 'request-senior-pending',
          viewerRole: UserProfileRole.senior,
          viewerId: 'current-senior',
        ),
        isFalse,
      );
    },
  );
}
