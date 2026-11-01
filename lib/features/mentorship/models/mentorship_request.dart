enum MentorshipRequestStatus { pending, accepted, rejected, cancelled }

class MentorshipRequest {
  const MentorshipRequest({
    required this.id,
    required this.requesterId,
    required this.alumniId,
    required this.focusArea,
    required this.cadence,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  final String id;
  final String requesterId;
  final String alumniId;
  final String focusArea;
  final String cadence;
  final String message;
  final MentorshipRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  MentorshipRequest copyWith({
    MentorshipRequestStatus? status,
    DateTime? respondedAt,
  }) => MentorshipRequest(
    id: id,
    requesterId: requesterId,
    alumniId: alumniId,
    focusArea: focusArea,
    cadence: cadence,
    message: message,
    status: status ?? this.status,
    createdAt: createdAt,
    respondedAt: respondedAt ?? this.respondedAt,
  );
}
