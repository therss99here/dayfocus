import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

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
            child: Text(
              'NOW',
              textAlign: TextAlign.center,
              style: AppTypography.micro(context),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 2, color: AppColors.accent),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
