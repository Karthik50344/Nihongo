import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Custom loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.primaryRed : AppColors.primaryRed;

    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          color: color ?? defaultColor,
          strokeWidth: 3,
        ),
      ),
    );
  }
}