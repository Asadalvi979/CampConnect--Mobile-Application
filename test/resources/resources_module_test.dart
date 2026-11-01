import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
import 'package:camp_connect/features/resources/models/resource.dart';
import 'package:camp_connect/features/resources/models/resource_report.dart';
import 'package:camp_connect/features/resources/screens/resource_upload_screen.dart';
import 'package:camp_connect/features/resources/services/resource_store.dart';
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
  setUp(() {
    ResourceStore.instance.resetMockData();
    UserProfileStore.instance.setRole(UserProfileRole.student);
  });

  testWidgets('resource library search and category filters published items', (
    tester,
  ) async {
    await _pumpApp(tester, route: AppRoutes.resources);
    expect(find.text('Resource Library'), findsOneWidget);
    expect(
      find.text('Data Structures & Algorithms - Complete Handwritten Notes'),
      findsOneWidget,
    );
    expect(
      find.text('Web Engineering Final Project Starter Code & APIs'),
      findsNothing,
    );

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ResourceCategory?>).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Past Papers').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(
      find.text('Database Systems Midterm Past Papers (2021-2024 Solved)'),
      findsOneWidget,
    );
    expect(
      find.text('Data Structures & Algorithms - Complete Handwritten Notes'),
      findsNothing,
    );

    await tester.enterText(find.byType(TextField).first, 'not-found-resource');
    await tester.pumpAndSettle();
    expect(find.text('No resources found'), findsOneWidget);
  });

  testWidgets('resource upload validates required fields and adds local item', (
    tester,
  ) async {
    await _pumpApp(tester, route: AppRoutes.resourceUpload);
    expect(find.byType(ResourceUploadScreen), findsOneWidget);
    expect(find.text('Upload Resource'), findsOneWidget);

    await tester.ensureVisible(find.text('Publish Resource'));
    await tester.tap(find.text('Publish Resource'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a resource title.'), findsOneWidget);

    final inputs = find.byType(TextFormField);
    await tester.ensureVisible(inputs.at(0));
    await tester.enterText(inputs.at(0), 'Temporary Study Resource');
    await tester.ensureVisible(inputs.at(1));
    await tester.enterText(inputs.at(1), 'A frontend-only sample resource.');
    await tester.ensureVisible(inputs.at(2));
    await tester.enterText(inputs.at(2), 'Computer Networks (CS-302)');
    await tester.ensureVisible(
      find.byType(DropdownButtonFormField<ResourceCategory>),
    );
    await tester.tap(find.byType(DropdownButtonFormField<ResourceCategory>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tap to select a mock document'));
    await tester.tap(find.text('Tap to select a mock document'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Course_Notes.pdf'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Publish Resource'));
    await tester.tap(find.text('Publish Resource'));
    await tester.pumpAndSettle();

    final created = ResourceStore.instance.resources.singleWhere(
      (resource) => resource.title == 'Temporary Study Resource',
    );
    expect(created.status, ResourceStatus.published);
    expect(created.fileUrl, startsWith('mock://'));
    expect(find.text('Resource Library'), findsOneWidget);
    expect(find.text('Temporary Study Resource'), findsOneWidget);
  });

  test('only published resources allow download previews', () {
    final store = ResourceStore.instance;
    expect(
      store.requestDownload('resource-database-papers'),
      ResourceDownloadResult.previewAllowed,
    );
    for (final id in [
      'resource-starter-code',
      'resource-textbook',
      'resource-removed-sample',
    ]) {
      expect(
        store.requestDownload(id),
        ResourceDownloadResult.unavailable,
        reason: '$id must not be downloadable',
      );
    }
  });

  test('reports do not alter status and admin decisions are authorized', () {
    final store = ResourceStore.instance;
    final before = store.resourceById('resource-database-papers')!.status;
    expect(
      store.reportResource(
        resourceId: 'resource-database-papers',
        reporterId: 'current-student',
        reporterRole: UserProfileRole.student,
        reason: ResourceReportReason.other,
        details: 'Temporary test report.',
      ),
      ResourceReportResult.submitted,
    );
    expect(store.resourceById('resource-database-papers')!.status, before);
    expect(
      store.reportResource(
        resourceId: 'resource-database-papers',
        reporterId: 'current-student',
        reporterRole: UserProfileRole.student,
        reason: ResourceReportReason.other,
        details: '',
      ),
      ResourceReportResult.duplicate,
    );

    expect(
      store.moderateReport(
        reportId: 'report-starter-code-seed',
        moderatorRole: UserProfileRole.student,
        moderatorId: 'current-student',
        decision: ResourceModerationDecision.keepPublished,
      ),
      ResourceModerationResult.unauthorized,
    );
    expect(
      store.resourceById('resource-starter-code')!.status,
      ResourceStatus.underReview,
    );
    expect(
      store.moderateReport(
        reportId: 'report-starter-code-seed',
        moderatorRole: UserProfileRole.admin,
        moderatorId: 'current-admin',
        decision: ResourceModerationDecision.keepPublished,
      ),
      ResourceModerationResult.updated,
    );
    expect(
      store.resourceById('resource-starter-code')!.status,
      ResourceStatus.published,
    );
  });

  testWidgets('student dashboard opens the resource library', (tester) async {
    await _pumpApp(tester, route: AppRoutes.studentDashboard);
    await tester.ensureVisible(find.text('Resources'));
    await tester.tap(find.text('Resources').first);
    await tester.pumpAndSettle();
    expect(find.text('Resource Library'), findsOneWidget);
  });

  testWidgets('library details and My Resources status navigation work', (
    tester,
  ) async {
    await _pumpApp(tester, route: AppRoutes.resources);
    await tester.tap(
      find.text('Data Structures & Algorithms - Complete Handwritten Notes'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Resource Details'), findsOneWidget);

    final detailsScrollable = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Report Resource'),
      300,
      scrollable: detailsScrollable,
    );
    await tester.tap(find.text('Report Resource'));
    await tester.pumpAndSettle();
    expect(find.text('Why are you reporting this resource?'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My Resources'));
    await tester.pumpAndSettle();
    expect(find.text('My Resources'), findsOneWidget);
    await tester.tap(find.text('Under Review').first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Web Engineering Final Project Starter Code & APIs'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Resource Status'), findsOneWidget);
    expect(find.text('Download unavailable (Under Review).'), findsOneWidget);
  });
}
