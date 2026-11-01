import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home_dashboard/models/dashboard_role.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../../project_collaboration/models/project_route_arguments.dart';
import '../data/community_mock_data.dart';
import '../models/post.dart';
import '../services/community_store.dart';

void showCommunityMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

class CommunityScaffold extends StatelessWidget {
  const CommunityScaffold({
    required this.title,
    required this.body,
    this.actions = const [],
    this.bottomNavigation = false,
    this.showBackButton = true,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool bottomNavigation;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      title: Text(title, style: const TextStyle(fontSize: 17)),
      actions: actions,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: body,
        ),
      ),
    ),
    bottomNavigationBar: bottomNavigation ? const CommunityBottomBar() : null,
  );
}

class CommunityBottomBar extends StatelessWidget {
  const CommunityBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileStore.instance.profile.value;
    final dashboardRole = switch (profile.role) {
      UserProfileRole.senior => DashboardRole.senior,
      UserProfileRole.alumni => DashboardRole.alumni,
      _ => DashboardRole.student,
    };
    final items = [
      (label: 'Home', icon: Icons.home_outlined, active: false),
      (label: 'Community', icon: Icons.groups_outlined, active: true),
      (label: 'Projects', icon: Icons.folder_open_outlined, active: false),
      (label: 'Messages', icon: Icons.chat_bubble_outline, active: false),
      (label: 'Profile', icon: Icons.person_outline, active: false),
    ];
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.lightBlue)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final item in items)
              InkWell(
                onTap: () {
                  switch (item.label) {
                    case 'Home':
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.dashboardRouteFor(dashboardRole));
                    case 'Community':
                      break;
                    case 'Projects':
                      Navigator.of(context).pushNamed(
                        AppRoutes.projects,
                        arguments: ProjectRouteArguments(
                          viewerRole: profile.role,
                        ),
                      );
                    case 'Messages':
                      openMessageInbox(context, viewerRole: profile.role);
                    case 'Profile':
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.profile, arguments: dashboardRole);
                    default:
                      showCommunityMessage(
                        context,
                        '${item.label} is not available in this preview yet.',
                      );
                  }
                },
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: item.active
                            ? AppColors.deepPrimary
                            : AppColors.secondaryText,
                        size: 21,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: item.active
                              ? AppColors.deepPrimary
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CommunityCardSurface extends StatelessWidget {
  const CommunityCardSurface({
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
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryText.withValues(alpha: 0.035),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar(this.name, {this.radius = 20, super.key});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part.isEmpty ? '' : part[0])
        .join()
        .toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightBlue,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.deepPrimary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.48,
        ),
      ),
    );
  }
}

class CommunityPill extends StatelessWidget {
  const CommunityPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.lightBlue,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, color: AppColors.deepPrimary),
    ),
  );
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    required this.post,
    required this.onOpen,
    super.key,
  });

  final CommunityPost post;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final author = post.authorId == CommunityMockData.currentUserId
        ? store.currentUserName()
        : CommunityMockData.userName(post.authorId);
    final isOwner = post.authorId == CommunityMockData.currentUserId;
    return CommunityCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommunityAvatar(author, radius: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${CommunityMockData.userRole(post.authorId)} • ${_timeAgo(post.createdAt)}',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                const CommunityPill('You')
              else
                const Icon(Icons.more_horiz, color: AppColors.mutedText),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onOpen,
            child: Text(
              post.content,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) => Wrap(
              spacing: 2,
              runSpacing: 0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => store.toggleLike(post.id),
                  icon: Icon(
                    store.isLiked(post.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 18,
                    color: store.isLiked(post.id)
                        ? AppColors.error
                        : AppColors.primaryText,
                  ),
                  label: Text('${store.likeCount(post.id)}'),
                ),
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text('${store.commentsFor(post.id).length} Comments'),
                ),
                TextButton(onPressed: onOpen, child: const Text('View Post')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inDays > 0) return '${difference.inDays}d ago';
  if (difference.inHours > 0) return '${difference.inHours}h ago';
  if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
  return 'Just now';
}
