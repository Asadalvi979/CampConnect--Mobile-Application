import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthProgress extends StatelessWidget {
  const AuthProgress({required this.step, required this.label, super.key});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: index < step
                    ? AppColors.deepPrimary
                    : AppColors.lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
