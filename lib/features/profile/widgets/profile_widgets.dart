import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../messaging/widgets/messaging_navigation.dart';
import '../models/user_profile.dart';

void showProfileMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

class ProfilePageScaffold extends StatelessWidget {
  const ProfilePageScaffold({
    required this.title,
    required this.child,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(title, style: const TextStyle(fontSize: 17)),
      actions: actions,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: child,
        ),
      ),
    ),
  );
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(15),
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

class ProfileSectionHeading extends StatelessWidget {
  const ProfileSectionHeading({
    required this.title,
    required this.icon,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 19, color: AppColors.deepPrimary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      ?trailing,
    ],
  );
}

class ProfileTag extends StatelessWidget {
  const ProfileTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.paleBlue,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: const TextStyle(fontSize: 10)),
  );
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.initials,
    this.radius = 42,
    this.badge = false,
    super.key,
  });

  final String initials;
  final double radius;
  final bool badge;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.lightBlue,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: radius * 0.48,
            fontWeight: FontWeight.w700,
            color: AppColors.deepPrimary,
          ),
        ),
      ),
      if (badge)
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
            ),
            child: const Icon(Icons.verified, size: 14, color: AppColors.white),
          ),
        ),
    ],
  );
}

class ProfileBottomBar extends StatelessWidget {
  const ProfileBottomBar({this.homeRoute = '/dashboard/student', super.key});

  final String homeRoute;

  @override
  Widget build(BuildContext context) => SafeArea(
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
          _item(context, Icons.home_outlined, 'Home', homeRoute),
          _item(
            context,
            Icons.groups_outlined,
            'Community',
            AppRoutes.communities,
          ),
          _item(
            context,
            Icons.folder_open_outlined,
            'Projects',
            AppRoutes.projects,
          ),
          _item(
            context,
            Icons.chat_bubble_outline,
            'Messages',
            AppRoutes.messages,
          ),
          _item(context, Icons.person_outline, 'Profile', null, active: true),
        ],
      ),
    ),
  );

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String? route, {
    bool active = false,
  }) => InkWell(
    onTap: route == null
        ? null
        : () {
            if (label == 'Messages') {
              openMessageInbox(
                context,
                viewerRole: UserProfileStore.instance.profile.value.role,
              );
            } else {
              Navigator.of(context).pushNamed(route);
            }
          },
    child: SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.deepPrimary : AppColors.secondaryText,
            size: 21,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? AppColors.deepPrimary : AppColors.secondaryText,
            ),
          ),
        ],
      ),
    ),
  );
}
