import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/katakana_model.dart';

/// Katakana card widget
class KatakanaCardWidget extends StatefulWidget {
  final KatakanaModel katakana;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const KatakanaCardWidget({
    super.key,
    required this.katakana,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  State<KatakanaCardWidget> createState() => _KatakanaCardWidgetState();
}

class _KatakanaCardWidgetState extends State<KatakanaCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: widget.onDoubleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: AppSizes.elevationM,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  AppColors.darkCardBackground,
                  AppColors.darkSurface,
                ]
                    : [
                  AppColors.lightCardBackground,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Katakana Character
                Text(
                  widget.katakana.character,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),

                // Romaji
                Text(
                  widget.katakana.romaji,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXS),

                // Pronunciation guide
                Text(
                  '(${widget.katakana.pronunciation})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}