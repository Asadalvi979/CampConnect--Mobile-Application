import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

const universityLogoAsset = 'Design/UI and UX/logo.png';

class AuthHeader extends StatelessWidget implements PreferredSizeWidget {
  const AuthHeader({required this.title, super.key});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.045),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Go back',
            icon: const Icon(Icons.arrow_back, size: 23),
            color: AppColors.primaryText,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Image.asset(
            universityLogoAsset,
            width: 28,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.deepPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
