import 'package:flutter/foundation.dart';

import '../../notifications_announcements/services/notification_announcement_store.dart';
import '../../profile/models/user_profile.dart';
import '../data/alumni_mock_data.dart';
import '../data/mentorship_mock_data.dart';
import '../models/alumni_mentor.dart';
import '../models/mentorship.dart';
import '../models/mentorship_member.dart';
import '../models/mentorship_request.dart';

enum RequestCreationResult { created, duplicate, unavailable, unauthorized }

class MentorshipStore extends ChangeNotifier {
  MentorshipStore._()
    : _requests = List.of(MentorshipMockData.initialRequests),
      _mentorships = [
        Mentorship(
          id: 'mentorship-seed',
          requestId: 'request-student-accepted',
          startedAt: DateTime(2025, 1, 22),
        ),
      ];

  static final MentorshipStore instance = MentorshipStore._();

  final List<MentorshipRequest> _requests;
  final List<Mentorship> _mentorships;
  int _nextRequestNumber = 1;

  List<MentorshipRequest> get requests => List.unmodifiable(_requests);
  List<Mentorship> get mentorships => List.unmodifiable(_mentorships);
  List<AlumniMentor> get alumni => AlumniMockData.mentors;

  String userIdFor(UserProfileRole role) => switch (role) {
    UserProfileRole.student => 'current-student',
    UserProfileRole.senior => 'current-senior',
    UserProfileRole.alumni => 'mentor-bilal',
    UserProfileRole.admin => 'current-admin',
  };

  MentorshipMember memberFor(String id, {UserProfileRole? currentViewerRole}) {
    final profile = UserProfileStore.instance.profile.value;
    if (id == userIdFor(profile.role)) {
      return MentorshipMember(
        id: id,
        name: profile.name,
        role: profile.role,
        program: profile.program,
        semester: profile.semester,
        university: profile.university,
        location: profile.location,
        cgpa: profile.cgpa,
      );
    }

    final mockMember = MentorshipMockData.members[id];
    if (mockMember != null) return mockMember;

    final role = switch (id) {
      'current-student' => UserProfileRole.student,
      'current-senior' => UserProfileRole.senior,
      _ => currentViewerRole ?? profile.role,
    };
    final profileMatchesRole = profile.role == role;
    return MentorshipMember(
      id: id,
      name: profileMatchesRole
          ? profile.name
          : switch (role) {
              UserProfileRole.student => 'Asadullah Sadiq',
              UserProfileRole.senior => 'Zainab Farooq',
              UserProfileRole.alumni => 'Bilal Ahmed',
              UserProfileRole.admin => 'CampConnect Admin',
            },
      role: role,
      program: profileMatchesRole
          ? profile.program
          : role == UserProfileRole.alumni
          ? 'BS Computer Science'
          : 'BS Software Engineering',
      semester: profileMatchesRole ? profile.semester : '8th Semester',
      university: profileMatchesRole
          ? profile.university
          : 'Riphah International University',
      location: profileMatchesRole ? profile.location : 'Sahiwal, Pakistan',
      cgpa: profileMatchesRole ? profile.cgpa : '3.72',
    );
  }

  AlumniMentor? mentorById(String id) {
    for (final mentor in alumni) {
      if (mentor.id == id) return mentor;
    }
    return null;
  }

  MentorshipRequest? requestById(String id) {
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  List<MentorshipRequest> sentRequests(String requesterId) =>
      _requests.where((request) => request.requesterId == requesterId).toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<MentorshipRequest> receivedRequests(String alumniId) =>
      _requests.where((request) => request.alumniId == alumniId).toList()
        ..sort((first, second) => second.createdAt.compareTo(first.createdAt));

  List<Mentorship> activeMentorshipsFor(String userId) =>
      _mentorships.where((relationship) {
          final request = requestById(relationship.requestId);
          return request != null &&
              request.status == MentorshipRequestStatus.accepted &&
              (request.requesterId == userId || request.alumniId == userId);
        }).toList()
        ..sort((first, second) => second.startedAt.compareTo(first.startedAt));

  RequestCreationResult createRequest({
    required UserProfileRole requesterRole,
    required String requesterId,
    required String alumniId,
    required String focusArea,
    required String cadence,
    required String message,
  }) {
    if (requesterRole != UserProfileRole.student &&
        requesterRole != UserProfileRole.senior) {
      return RequestCreationResult.unauthorized;
    }
    final mentor = mentorById(alumniId);
    if (mentor == null || !mentor.acceptsRequests || mentor.openSpots == 0) {
      return RequestCreationResult.unavailable;
    }
    final alreadyExists = _requests.any(
      (request) =>
          request.requesterId == requesterId &&
          request.alumniId == alumniId &&
          (request.status == MentorshipRequestStatus.pending ||
              request.status == MentorshipRequestStatus.accepted),
    );
    if (alreadyExists) return RequestCreationResult.duplicate;

    _requests.add(
      MentorshipRequest(
        id: 'request-local-${_nextRequestNumber++}',
        requesterId: requesterId,
        alumniId: alumniId,
        focusArea: focusArea,
        cadence: cadence,
        message: message.trim(),
        status: MentorshipRequestStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return RequestCreationResult.created;
  }

  bool acceptRequest({
    required String requestId,
    required UserProfileRole viewerRole,
    required String viewerId,
  }) => _updatePendingRequest(
    requestId: requestId,
    viewerRole: viewerRole,
    viewerId: viewerId,
    status: MentorshipRequestStatus.accepted,
  );

  bool rejectRequest({
    required String requestId,
    required UserProfileRole viewerRole,
    required String viewerId,
  }) => _updatePendingRequest(
    requestId: requestId,
    viewerRole: viewerRole,
    viewerId: viewerId,
    status: MentorshipRequestStatus.rejected,
  );

  bool cancelRequest({required String requestId, required String requesterId}) {
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index < 0 ||
        _requests[index].requesterId != requesterId ||
        _requests[index].status != MentorshipRequestStatus.pending) {
      return false;
    }
    _requests[index] = _requests[index].copyWith(
      status: MentorshipRequestStatus.cancelled,
      respondedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  bool _updatePendingRequest({
    required String requestId,
    required UserProfileRole viewerRole,
    required String viewerId,
    required MentorshipRequestStatus status,
  }) {
    if (viewerRole != UserProfileRole.alumni) return false;
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index < 0 ||
        _requests[index].alumniId != viewerId ||
        _requests[index].status != MentorshipRequestStatus.pending) {
      return false;
    }

    final updatedAt = DateTime.now();
    final request = _requests[index].copyWith(
      status: status,
      respondedAt: updatedAt,
    );
    _requests[index] = request;

    if (status == MentorshipRequestStatus.accepted) {
      _mentorships.add(
        Mentorship(
          id: 'mentorship-${request.id}',
          requestId: request.id,
          startedAt: updatedAt,
        ),
      );
      NotificationAnnouncementStore.instance.addActivityNotification(
        recipientId: request.requesterId,
        type: 'Mentorship',
        message: 'Your mentorship request was accepted.',
      );
    }
    notifyListeners();
    return true;
  }
}
