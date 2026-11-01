import 'package:camp_connect/features/messaging/models/friendship.dart';
import 'package:camp_connect/features/messaging/services/messaging_store.dart';
import 'package:camp_connect/features/navigation/app_routes.dart';
import 'package:camp_connect/features/profile/models/user_profile.dart';
import 'package:camp_connect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    UserProfileStore.instance.setRole(UserProfileRole.student);
  });

  test('friendship and mentorship permissions remain independent', () {
    final store = MessagingStore.instance;

    final activeFriendConversation = store.openFriendConversation(
      viewerId: 'current-student',
      peerId: 'senior-zainab',
    );
    expect(activeFriendConversation, isNotNull);
    expect(activeFriendConversation!.friendshipId, isNotNull);
    expect(activeFriendConversation.mentorshipId, isNull);
    expect(
      store.isAuthorizedFor(activeFriendConversation.id, 'current-student'),
      isTrue,
    );

    expect(
      store.openFriendConversation(
        viewerId: 'current-student',
        peerId: 'student-danish',
      ),
      isNull,
    );
    expect(
      store.openFriendConversation(
        viewerId: 'current-student',
        peerId: 'senior-hira',
      ),
      isNull,
    );
    expect(
      store.respondToFriendRequest(
        requestId: 'friend-request-hira',
        viewerId: 'current-student',
        accept: false,
      ),
      FriendRequestUpdateResult.updated,
    );
    expect(
      store.activeFriendshipBetween('current-student', 'senior-hira'),
      isNull,
    );
    expect(
      store.openFriendConversation(
        viewerId: 'current-student',
        peerId: 'senior-hira',
      ),
      isNull,
    );

    final mentorshipConversation = store.openMentorshipConversation(
      viewerId: 'current-student',
      requestId: 'request-student-accepted',
    );
    expect(mentorshipConversation, isNotNull);
    expect(mentorshipConversation!.friendshipId, isNull);
    expect(mentorshipConversation.mentorshipId, isNotNull);
    expect(
      store.isAuthorizedFor(mentorshipConversation.id, 'current-student'),
      isTrue,
    );
    expect(
      store.activeFriendshipBetween('current-student', 'mentor-ayesha'),
      isNull,
    );
    expect(
      store.openMentorshipConversation(
        viewerId: 'current-student',
        requestId: 'request-student-pending',
      ),
      isNull,
    );
  });

  test('accepting a friend request grants access and removal revokes it', () {
    final store = MessagingStore.instance;
    final result = store.respondToFriendRequest(
      requestId: 'friend-request-danish',
      viewerId: 'current-student',
      accept: true,
    );
    expect(result, FriendRequestUpdateResult.updated);
    expect(
      store.activeFriendshipBetween('current-student', 'student-danish'),
      isNotNull,
    );
    final conversation = store.openFriendConversation(
      viewerId: 'current-student',
      peerId: 'student-danish',
    );
    expect(conversation, isNotNull);
    expect(conversation!.friendshipId, isNotNull);
    expect(conversation.mentorshipId, isNull);

    final friendship = store.friendships.firstWhere(
      (item) => item.connects('current-student', 'senior-hamza'),
    );
    expect(friendship.status, FriendshipStatus.active);
    expect(
      store.removeFriendship(
        friendshipId: friendship.id,
        viewerId: 'current-student',
      ),
      isTrue,
    );
    final removedConversation = store
        .conversationsFor('current-student')
        .where((item) => item.friendshipId == friendship.id);
    expect(removedConversation, isEmpty);
  });

  testWidgets('chat sends text and displays a mock attachment preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const CampConnectApp(initialRoute: AppRoutes.messages),
    );
    await tester.pumpAndSettle();
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Zainab Farooq'), findsOneWidget);

    await tester.tap(find.text('Zainab Farooq'));
    await tester.pumpAndSettle();
    expect(
      find.text('Hey! How is your semester project going?'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextField).last,
      'The frontend collaboration is ready.',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('The frontend collaboration is ready.'), findsOneWidget);

    await tester.tap(find.byTooltip('Attach local mock file'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mock image'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('campus-project.jpg'), findsOneWidget);

    await tester.tap(find.text('campus-project.jpg'));
    await tester.pumpAndSettle();
    expect(find.text('Image preview'), findsOneWidget);
    expect(find.textContaining('Local mock preview only'), findsOneWidget);
  });
}
