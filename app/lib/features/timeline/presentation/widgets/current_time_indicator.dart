import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CurrentTimeIndicator extends StatelessWidget {
  const CurrentTimeIndicator({super.key, required this.topOffset});

  final double topOffset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset - 8,
      left: 0,
      right: 0,
      height: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: AppSpacing.timelineLabelWidth,
            child: const Text(
              'NOW',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 1.5, color: AppColors.accent),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
