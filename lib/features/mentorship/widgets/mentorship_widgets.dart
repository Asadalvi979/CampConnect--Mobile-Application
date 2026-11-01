import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../models/mentorship_route_arguments.dart';

class MentorshipPage extends StatelessWidget {
  const MentorshipPage({
    required this.title,
    required this.child,
    this.actions,
    this.bottom,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: child,
        ),
      ),
    ),
    bottomNavigationBar: bottom,
  );
}

class MentorshipCard extends StatelessWidget {
  const MentorshipCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.white,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryText.withValues(alpha: 0.035),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}

class MentorAvatar extends StatelessWidget {
  const MentorAvatar(this.name, {this.radius = 24, super.key});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightBlue,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.deepPrimary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }
}

class MentorshipTag extends StatelessWidget {
  const MentorshipTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.deepPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class MentorshipStatusTag extends StatelessWidget {
  const MentorshipStatusTag(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'accepted' => AppColors.success,
      'rejected' || 'cancelled' => AppColors.error,
      _ => AppColors.deepPrimary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class MentorshipEmptyState extends StatelessWidget {
  const MentorshipEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.handshake_outlined,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.deepPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

void showMentorshipMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.deepPrimary,
      ),
    );
}

void openMentorshipDirectory(
  BuildContext context, {
  required UserProfileRole role,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.mentorship,
    arguments: MentorshipRouteArguments(viewerRole: role),
  );
}

void openMentorshipRequests(
  BuildContext context, {
  required UserProfileRole role,
  int? initialTab,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.mentorshipRequests,
    arguments: MentorshipRouteArguments(
      viewerRole: role,
      initialTab: initialTab,
    ),
  );
}

void openActiveMentorships(
  BuildContext context, {
  required UserProfileRole role,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.activeMentorships,
    arguments: MentorshipRouteArguments(viewerRole: role),
  );
}

void openAlumniProfile(
  BuildContext context, {
  required UserProfileRole role,
  required String alumniId,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.alumniProfile,
    arguments: MentorshipRouteArguments(viewerRole: role, alumniId: alumniId),
  );
}

void openRequestMentorship(
  BuildContext context, {
  required UserProfileRole role,
  required String alumniId,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.mentorshipRequest,
    arguments: MentorshipRouteArguments(viewerRole: role, alumniId: alumniId),
  );
}

void openMentorshipRequestDetails(
  BuildContext context, {
  required UserProfileRole role,
  required String requestId,
}) {
  Navigator.of(context).pushNamed(
    AppRoutes.mentorshipRequestDetails,
    arguments: MentorshipRouteArguments(viewerRole: role, requestId: requestId),
  );
}
