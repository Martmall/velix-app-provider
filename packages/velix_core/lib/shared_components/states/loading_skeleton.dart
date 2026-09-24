import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';

class LoadingSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardDark,
      highlightColor: AppColors.cardDarkElevated,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
