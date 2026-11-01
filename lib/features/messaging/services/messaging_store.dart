import 'package:flutter/foundation.dart';

import '../../mentorship/models/mentorship_request.dart';
import '../../mentorship/services/mentorship_store.dart';
import '../../notifications_announcements/services/notification_announcement_store.dart';
import '../../profile/models/user_profile.dart';
import '../data/messaging_mock_data.dart';
import '../models/conversation_participant.dart';
import '../models/friend_request.dart';
import '../models/friendship.dart';
import '../models/message.dart';
import '../models/message_attachment.dart';
import '../models/messaging_contact.dart';
import '../models/messaging_conversation.dart';

enum MessageSendResult { sent, empty, unauthorized }

enum FriendRequestUpdateResult { updated, unavailable, unauthorized }

class MessagingStore extends ChangeNotifier {
  MessagingStore._()
    : _friendships = List.of(MessagingMockData.initialFriendships),
      _friendRequests = List.of(MessagingMockData.initialFriendRequests) {
    final viewerId = MentorshipStore.instance.userIdFor(
      UserProfileStore.instance.profile.value.role,
    );
    conversationsFor(viewerId);
  }

  static final MessagingStore instance = MessagingStore._();

  final List<Friendship> _friendships;
  final List<FriendRequest> _friendRequests;
  final List<MessagingConversation> _conversations = [];
  final List<ConversationParticipant> _participants = [];
  final List<MessagingMessage> _messages = [];
  final List<MessageAttachment> _attachments = [];
  int _nextConversationNumber = 1;
  int _nextMessageNumber = 1;
  int _nextAttachmentNumber = 1;
  int _nextFriendshipNumber = 1;

  List<Friendship> get friendships => List.unmodifiable(_friendships);
  List<FriendRequest> get friendRequests => List.unmodifiable(_friendRequests);
  List<MessagingConversation> get conversations =>
      List.unmodifiable(_conversations);
  List<MessagingMessage> get messages => List.unmodifiable(_messages);
  List<MessageAttachment> get attachments => List.unmodifiable(_attachments);

  String currentUserId(UserProfileRole role) =>
      MentorshipStore.instance.userIdFor(role);

  MessagingContact contactFor(String id) {
    final profile = UserProfileStore.instance.profile.value;
    if (id == currentUserId(profile.role)) {
      return MessagingContact(
        id: id,
        name: profile.name,
        role: profile.role,
        headline: '${profile.roleLabel} · ${profile.program}',
        program: profile.program,
        department: profile.department,
      );
    }
    if (id.startsWith('mentor-')) {
      final mentor = MentorshipStore.instance.mentorById(id);
      if (mentor != null) {
        return MessagingContact(
          id: id,
          name: mentor.name,
          role: UserProfileRole.alumni,
          headline: mentor.headline,
          program: mentor.degree,
          department: mentor.department,
        );
      }
    }
    final mockContact = MessagingMockData.contacts[id];
    if (mockContact != null) return mockContact;
    final member = MentorshipStore.instance.memberFor(id);
    return MessagingContact(
      id: id,
      name: member.name,
      role: member.role,
      headline: member.roleLabel,
      program: member.program,
      department: member.university,
    );
  }

  List<Friendship> activeFriendshipsFor(String userId) {
    return _friendships
        .where(
          (friendship) =>
              friendship.status == FriendshipStatus.active &&
              (friendship.user1Id == userId || friendship.user2Id == userId),
        )
        .toList();
  }

  List<String> friendsFor(String userId) => activeFriendshipsFor(userId)
      .map(
        (friendship) => friendship.user1Id == userId
            ? friendship.user2Id
            : friendship.user1Id,
      )
      .toList();

  Friendship? activeFriendshipBetween(String first, String second) {
    for (final friendship in _friendships) {
      if (friendship.status == FriendshipStatus.active &&
          friendship.connects(first, second)) {
        return friendship;
      }
    }
    return null;
  }

  List<FriendRequest> receivedRequestsFor(String userId) =>
      _friendRequests
          .where(
            (request) =>
                request.receiverId == userId &&
                request.status == FriendRequestStatus.pending,
          )
          .toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<FriendRequest> sentRequestsFor(String userId) =>
      _friendRequests
          .where(
            (request) =>
                request.senderId == userId &&
                request.status == FriendRequestStatus.pending,
          )
          .toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<MessagingConversation> conversationsFor(String userId) {
    for (final friendship in activeFriendshipsFor(userId)) {
      final peerId = friendship.user1Id == userId
          ? friendship.user2Id
          : friendship.user1Id;
      _ensureFriendshipConversation(userId, peerId, friendship.id);
    }
    for (final relationship in MentorshipStore.instance.activeMentorshipsFor(
      userId,
    )) {
      final request = MentorshipStore.instance.requestById(
        relationship.requestId,
      );
      if (request == null) continue;
      final peerId = request.requesterId == userId
          ? request.alumniId
          : request.requesterId;
      _ensureMentorshipConversation(
        userId: userId,
        peerId: peerId,
        mentorshipId: relationship.id,
      );
    }
    return _conversations
        .where((conversation) => isAuthorizedFor(conversation.id, userId))
        .toList()
      ..sort((first, second) {
        final firstMessage = latestMessage(first.id)?.sentAt ?? first.createdAt;
        final secondMessage =
            latestMessage(second.id)?.sentAt ?? second.createdAt;
        return secondMessage.compareTo(firstMessage);
      });
  }

  MessagingConversation? conversationById(String id) {
    for (final conversation in _conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  MessagingMessage? messageById(String id) {
    for (final message in _messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  String? peerIdFor(String conversationId, String viewerId) {
    for (final participant in _participants) {
      if (participant.conversationId == conversationId &&
          participant.userId != viewerId) {
        return participant.userId;
      }
    }
    return null;
  }

  bool isAuthorizedFor(String conversationId, String viewerId) {
    final conversation = conversationById(conversationId);
    if (conversation == null) return false;
    final participants = _participants
        .where((item) => item.conversationId == conversationId)
        .map((item) => item.userId)
        .toSet();
    if (!participants.contains(viewerId) || participants.length != 2) {
      return false;
    }

    final peerId = participants.firstWhere((id) => id != viewerId);
    if (conversation.friendshipId case final friendshipId?) {
      if (conversation.mentorshipId != null) return false;
      final friendship = _friendships
          .where((item) => item.id == friendshipId)
          .firstOrNull;
      return friendship != null &&
          friendship.status == FriendshipStatus.active &&
          friendship.connects(viewerId, peerId);
    }
    if (conversation.mentorshipId case final mentorshipId?) {
      if (conversation.friendshipId != null) return false;
      final store = MentorshipStore.instance;
      final relationship = store.mentorships
          .where((item) => item.id == mentorshipId)
          .firstOrNull;
      if (relationship == null) return false;
      final request = store.requestById(relationship.requestId);
      return request != null &&
          request.status == MentorshipRequestStatus.accepted &&
          ((request.requesterId == viewerId && request.alumniId == peerId) ||
              (request.alumniId == viewerId && request.requesterId == peerId));
    }
    return false;
  }

  List<MessagingMessage> messagesFor(String conversationId) =>
      _messages
          .where((message) => message.conversationId == conversationId)
          .toList()
        ..sort((first, second) => first.sentAt.compareTo(second.sentAt));

  MessagingMessage? latestMessage(String conversationId) {
    final messages = messagesFor(conversationId);
    return messages.isEmpty ? null : messages.last;
  }

  List<MessageAttachment> attachmentsFor(String messageId) => _attachments
      .where((attachment) => attachment.messageId == messageId)
      .toList();

  MessageSendResult sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    required List<MockAttachmentDraft> attachments,
  }) {
    if (!isAuthorizedFor(conversationId, senderId)) {
      return MessageSendResult.unauthorized;
    }
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty && attachments.isEmpty) {
      return MessageSendResult.empty;
    }

    final messageId = 'message-local-${_nextMessageNumber++}';
    _messages.add(
      MessagingMessage(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        content: trimmedContent.isEmpty ? null : trimmedContent,
        sentAt: DateTime.now(),
      ),
    );
    for (final draft in attachments) {
      _attachments.add(
        MessageAttachment(
          id: 'attachment-local-${_nextAttachmentNumber++}',
          messageId: messageId,
          fileUrl: 'mock://${draft.fileName}',
          fileName: draft.fileName,
          fileType: draft.fileType,
          fileSizeKb: draft.fileSizeKb,
        ),
      );
    }
    notifyListeners();
    return MessageSendResult.sent;
  }

  MessagingConversation? openFriendConversation({
    required String viewerId,
    required String peerId,
  }) {
    if (viewerId == peerId) return null;
    final friendship = activeFriendshipBetween(viewerId, peerId);
    if (friendship == null) return null;
    final conversation = _ensureFriendshipConversation(
      viewerId,
      peerId,
      friendship.id,
    );
    notifyListeners();
    return isAuthorizedFor(conversation.id, viewerId) ? conversation : null;
  }

  MessagingConversation? openMentorshipConversation({
    required String viewerId,
    required String requestId,
  }) {
    final store = MentorshipStore.instance;
    final request = store.requestById(requestId);
    final relationship = store.mentorships
        .where((item) => item.requestId == requestId)
        .firstOrNull;
    if (request == null ||
        relationship == null ||
        request.status != MentorshipRequestStatus.accepted ||
        (request.requesterId != viewerId && request.alumniId != viewerId)) {
      return null;
    }
    final peerId = request.requesterId == viewerId
        ? request.alumniId
        : request.requesterId;
    final conversation = _ensureMentorshipConversation(
      userId: viewerId,
      peerId: peerId,
      mentorshipId: relationship.id,
    );
    notifyListeners();
    return isAuthorizedFor(conversation.id, viewerId) ? conversation : null;
  }

  FriendRequestUpdateResult respondToFriendRequest({
    required String requestId,
    required String viewerId,
    required bool accept,
  }) {
    final index = _friendRequests.indexWhere((item) => item.id == requestId);
    if (index < 0 ||
        _friendRequests[index].receiverId != viewerId ||
        _friendRequests[index].status != FriendRequestStatus.pending) {
      return FriendRequestUpdateResult.unauthorized;
    }
    final request = _friendRequests[index];
    final status = accept
        ? FriendRequestStatus.accepted
        : FriendRequestStatus.rejected;
    _friendRequests[index] = request.copyWith(
      status: status,
      respondedAt: DateTime.now(),
    );
    if (accept &&
        activeFriendshipBetween(request.senderId, request.receiverId) == null) {
      _friendships.add(
        Friendship(
          id: 'friendship-local-${_nextFriendshipNumber++}',
          user1Id: request.senderId,
          user2Id: request.receiverId,
          status: FriendshipStatus.active,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (accept) {
      NotificationAnnouncementStore.instance.addActivityNotification(
        recipientId: request.senderId,
        type: 'Message request',
        message: 'Your campus connection request was accepted.',
      );
    }
    notifyListeners();
    return FriendRequestUpdateResult.updated;
  }

  bool removeFriendship({
    required String friendshipId,
    required String viewerId,
  }) {
    final index = _friendships.indexWhere((item) => item.id == friendshipId);
    if (index < 0 ||
        _friendships[index].status != FriendshipStatus.active ||
        (_friendships[index].user1Id != viewerId &&
            _friendships[index].user2Id != viewerId)) {
      return false;
    }
    _friendships[index] = _friendships[index].copyWith(
      status: FriendshipStatus.removed,
      endedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  MessagingConversation _ensureFriendshipConversation(
    String userId,
    String peerId,
    String friendshipId,
  ) {
    for (final conversation in _conversations) {
      if (conversation.friendshipId == friendshipId &&
          conversation.mentorshipId == null) {
        return conversation;
      }
    }
    final conversation = MessagingConversation(
      id: 'conversation-local-${_nextConversationNumber++}',
      friendshipId: friendshipId,
      createdAt: DateTime.now(),
    );
    _addConversation(conversation, userId, peerId);
    _seedMessages(conversation.id, peerId, userId);
    return conversation;
  }

  MessagingConversation _ensureMentorshipConversation({
    required String userId,
    required String peerId,
    required String mentorshipId,
  }) {
    for (final conversation in _conversations) {
      if (conversation.mentorshipId == mentorshipId &&
          conversation.friendshipId == null) {
        return conversation;
      }
    }
    final conversation = MessagingConversation(
      id: 'conversation-local-${_nextConversationNumber++}',
      mentorshipId: mentorshipId,
      createdAt: DateTime.now(),
    );
    _addConversation(conversation, userId, peerId);
    _seedMessages(conversation.id, peerId, userId);
    return conversation;
  }

  void _addConversation(
    MessagingConversation conversation,
    String firstUserId,
    String secondUserId,
  ) {
    _conversations.add(conversation);
    final joinedAt = DateTime.now();
    _participants
      ..add(
        ConversationParticipant(
          conversationId: conversation.id,
          userId: firstUserId,
          joinedAt: joinedAt,
        ),
      )
      ..add(
        ConversationParticipant(
          conversationId: conversation.id,
          userId: secondUserId,
          joinedAt: joinedAt,
        ),
      );
  }

  void _seedMessages(String conversationId, String peerId, String viewerId) {
    final isAyesha = peerId == 'mentor-ayesha';
    _messages.add(
      MessagingMessage(
        id: 'message-seed-${_nextMessageNumber++}',
        conversationId: conversationId,
        senderId: peerId,
        content: isAyesha
            ? 'Hi! I reviewed your project idea. It has a lot of potential.'
            : 'Hey! How is your semester project going?',
        sentAt: DateTime(2025, 2, 18, 10, 30),
        readAt: DateTime(2025, 2, 18, 10, 32),
      ),
    );
    _messages.add(
      MessagingMessage(
        id: 'message-seed-${_nextMessageNumber++}',
        conversationId: conversationId,
        senderId: viewerId,
        content: isAyesha
            ? 'Thank you! I would love your feedback on the next steps.'
            : 'It is going well, thanks for checking in!',
        sentAt: DateTime(2025, 2, 18, 10, 35),
        readAt: DateTime(2025, 2, 18, 10, 40),
      ),
    );
  }
}

class MockAttachmentDraft {
  const MockAttachmentDraft({
    required this.fileName,
    required this.fileType,
    required this.fileSizeKb,
  });

  final String fileName;
  final String fileType;
  final int fileSizeKb;

  bool get isImage => fileType.startsWith('image/');
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
