import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
import 'package:camp_connect/features/project_collaboration/models/project_interest.dart';
import 'package:camp_connect/features/project_collaboration/models/project_opportunity.dart';
import 'package:camp_connect/features/project_collaboration/models/project_route_arguments.dart';
import 'package:camp_connect/features/project_collaboration/services/project_collaboration_store.dart';
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
  testWidgets('project discovery search opens details and returns correctly', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.student);
    await _pumpApp(tester, route: AppRoutes.projects);

    expect(find.text('Project List'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'recommendation');
    await tester.pumpAndSettle();
    expect(find.text('Machine Learning Recommendation System'), findsWidgets);
    expect(find.text('AI-Based Student Assistant'), findsNothing);

    await tester.tap(find.text('Machine Learning Recommendation System').first);
    await tester.pumpAndSettle();
    expect(find.text('Project Details'), findsOneWidget);
    expect(find.text('Required Technical Skills'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Project List'), findsOneWidget);
    expect(find.text('Machine Learning Recommendation System'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(-450, 0));
    await tester.drag(find.byType(ListView).first, const Offset(-150, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Machine Learning'));
    await tester.pumpAndSettle();
    expect(find.text('Machine Learning Recommendation System'), findsWidgets);
    expect(find.text('AI-Based Student Assistant'), findsNothing);
  });

  testWidgets('create project form validates required information', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.student);
    await _pumpApp(tester, route: AppRoutes.projects);

    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();
    expect(find.text('Create Project'), findsOneWidget);

    await tester.tap(find.text('Publish Project'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsNWidgets(3));
    expect(find.text('Select a project category.'), findsOneWidget);
  });

  testWidgets('project creation and editing update the shared list', (
    tester,
  ) async {
    final store = ProjectCollaborationStore.instance;
    final previousRole = UserProfileStore.instance.profile.value.role;
    final previousProjects = List.of(store.opportunities);
    final previousInterests = List.of(store.interests);
    addTearDown(() {
      store.opportunities
        ..clear()
        ..addAll(previousProjects);
      store.interests
        ..clear()
        ..addAll(previousInterests);
      store.notifyListeners();
      UserProfileStore.instance.setRole(previousRole);
    });
    UserProfileStore.instance.setRole(UserProfileRole.student);
    await _pumpApp(tester, route: AppRoutes.projects);

    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Widget Test Collaboration',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'A locally created project opportunity for widget testing.',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Looking for one Flutter contributor.',
    );
    await tester.enterText(find.byType(TextField).last, 'Flutter');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter'), findsOneWidget);
    await tester.tap(find.text('Publish Project'));
    await tester.pumpAndSettle();

    expect(
      store.opportunities.any(
        (project) => project.title == 'Widget Test Collaboration',
      ),
      isTrue,
      reason: 'The project form should publish the entered information to local state.',
    );
    expect(find.text('Widget Test Collaboration'), findsWidgets);
    await tester.tap(find.text('Widget Test Collaboration').first);
    await tester.pumpAndSettle();
    expect(find.text('Project Details'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit project'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Updated Widget Test Project',
    );
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Updated Widget Test Project'), findsOneWidget);
  });

  testWidgets('project owner can review an incoming interest', (tester) async {
    final store = ProjectCollaborationStore.instance;
    final previousRole = UserProfileStore.instance.profile.value.role;
    final previousInterests = List.of(store.interests);
    addTearDown(() {
      store.interests
        ..clear()
        ..addAll(previousInterests);
      store.notifyListeners();
      UserProfileStore.instance.setRole(previousRole);
    });
    UserProfileStore.instance.setRole(UserProfileRole.student);
    await _pumpApp(tester, route: AppRoutes.projects);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      AppRoutes.projectInterests,
      arguments: const ProjectRouteArguments(
        viewerRole: UserProfileRole.student,
        projectId: 'project-ai-assistant',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Project Interests'), findsOneWidget);
    await tester.tap(find.text('Areeba Khan'));
    await tester.pumpAndSettle();
    expect(find.text('Interest Details'), findsOneWidget);
    await tester.tap(find.text('Accept Interest'));
    await tester.pumpAndSettle();

    expect(find.text('Project Interests'), findsOneWidget);
    expect(find.text('Pending (0)'), findsOneWidget);
    expect(
      store.interest('project-ai-assistant', 'project-user-areeba')?.status,
      ProjectInterestStatus.accepted,
    );
  });

  testWidgets('interest form validates the message, skills, and availability', (
    tester,
  ) async {
    UserProfileStore.instance.setRole(UserProfileRole.student);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const CampConnectApp(initialRoute: AppRoutes.projects),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(
      AppRoutes.projectExpressInterest,
      arguments: const ProjectRouteArguments(
        viewerRole: UserProfileRole.student,
        projectId: 'project-recommendation',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Interest'));
    await tester.pumpAndSettle();
    expect(find.text('Please write at least 10 characters.'), findsOneWidget);
    expect(find.text('Select your weekly availability.'), findsOneWidget);
    expect(find.text('Select at least one skill.'), findsOneWidget);
  });

  test(
    'interest submissions prevent duplicates and owner decisions update team',
    () {
      final store = ProjectCollaborationStore.instance;
      final profileStore = UserProfileStore.instance;
      final previousRole = profileStore.profile.value.role;
      final previousProjects = List.of(store.opportunities);
      final previousInterests = List.of(store.interests);
      addTearDown(() {
        store.opportunities
          ..clear()
          ..addAll(previousProjects);
        store.interests
          ..clear()
          ..addAll(previousInterests);
        store.notifyListeners();
        profileStore.setRole(previousRole);
      });
      profileStore.setRole(UserProfileRole.student);

      final acceptedProject = store.createProject(
        creatorRole: UserProfileRole.senior,
        creatorId: store.userIdFor(UserProfileRole.senior),
        title: 'Local state acceptance test',
        description: 'A project used to verify accepted interest handling.',
        category: 'Other',
        requiredSkills: const ['Flutter'],
        teamRequirements: 'Looking for a Flutter contributor.',
        desiredTeamSize: 3,
      )!;
      final submitted = store.submitInterest(
        projectId: acceptedProject.id,
        applicantRole: UserProfileRole.student,
        applicantId: store.userIdFor(UserProfileRole.student),
        message: 'I can contribute to the application interface.',
        selectedSkills: const ['Flutter'],
        weeklyAvailability: '5–8 hours per week',
      );
      expect(submitted, SubmitProjectResult.created);
      expect(
        store.submitInterest(
          projectId: acceptedProject.id,
          applicantRole: UserProfileRole.student,
          applicantId: store.userIdFor(UserProfileRole.student),
          message: 'Trying to send a duplicate interest.',
          selectedSkills: const ['Flutter'],
          weeklyAvailability: '5–8 hours per week',
        ),
        SubmitProjectResult.duplicate,
      );
      expect(
        store.submitInterest(
          projectId: acceptedProject.id,
          applicantRole: UserProfileRole.alumni,
          applicantId: store.userIdFor(UserProfileRole.alumni),
          message: 'This role cannot submit a project interest.',
          selectedSkills: const ['Flutter'],
          weeklyAvailability: '5–8 hours per week',
        ),
        SubmitProjectResult.unauthorized,
      );
      expect(
        store.decideInterest(
          projectId: acceptedProject.id,
          applicantId: store.userIdFor(UserProfileRole.student),
          ownerId: 'not-the-project-owner',
          decision: ProjectInterestStatus.accepted,
        ),
        ProjectDecisionResult.unauthorized,
      );
      expect(
        store.decideInterest(
          projectId: acceptedProject.id,
          applicantId: store.userIdFor(UserProfileRole.student),
          ownerId: store.userIdFor(UserProfileRole.senior),
          decision: ProjectInterestStatus.accepted,
        ),
        ProjectDecisionResult.updated,
      );
      expect(store.memberCount(acceptedProject), 2);
      expect(
        store
            .interest(
              acceptedProject.id,
              store.userIdFor(UserProfileRole.student),
            )
            ?.status,
        ProjectInterestStatus.accepted,
      );

      final rejectedProject = store.createProject(
        creatorRole: UserProfileRole.senior,
        creatorId: store.userIdFor(UserProfileRole.senior),
        title: 'Local state rejection test',
        description: 'A project used to verify rejected interest handling.',
        category: 'Other',
        requiredSkills: const ['Flutter'],
        teamRequirements: 'Looking for a Flutter contributor.',
        desiredTeamSize: 3,
      )!;
      store.submitInterest(
        projectId: rejectedProject.id,
        applicantRole: UserProfileRole.student,
        applicantId: store.userIdFor(UserProfileRole.student),
        message: 'I can contribute to this local project.',
        selectedSkills: const ['Flutter'],
        weeklyAvailability: '5–8 hours per week',
      );
      expect(
        store.decideInterest(
          projectId: rejectedProject.id,
          applicantId: store.userIdFor(UserProfileRole.student),
          ownerId: store.userIdFor(UserProfileRole.senior),
          decision: ProjectInterestStatus.rejected,
        ),
        ProjectDecisionResult.updated,
      );
      expect(store.memberCount(rejectedProject), 1);
      expect(
        store
            .interest(
              rejectedProject.id,
              store.userIdFor(UserProfileRole.student),
            )
            ?.status,
        ProjectInterestStatus.rejected,
      );
      expect(
        store.closeProject(
          projectId: rejectedProject.id,
          ownerId: 'not-the-project-owner',
        ),
        isFalse,
      );
      expect(
        store.closeProject(
          projectId: rejectedProject.id,
          ownerId: store.userIdFor(UserProfileRole.senior),
        ),
        isTrue,
      );
      expect(
        store.project(rejectedProject.id)?.status,
        ProjectOpportunityStatus.closed,
      );
    },
  );
}
