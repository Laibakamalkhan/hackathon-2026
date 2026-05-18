import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ai_seekho_flutter/app/theme.dart';

class BlobBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const BlobBackground({
    super.key,
    required this.child,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid background base
        Container(
          color: isDarkMode ? AppColors.bgDark : AppColors.bgPrimary,
        ),
        
        // Blurred accent spots (light mode has warm blush & soft lavender blobs)
        if (!isDarkMode) ...[
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lavender.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgSecondary.withOpacity(0.6),
              ),
            ),
          ),
        ] else ...[
          // Dark mode subtle ambient blobs for Provider Dashboard
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lavender.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sand.withOpacity(0.08),
              ),
            ),
          ),
        ],

        // Backdrop blur overlay to smear the circles beautifully
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Main content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
