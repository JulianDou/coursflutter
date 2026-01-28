import 'dart:ui';

import 'package:flutter/material.dart';

/// Glassmorphism glass container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final bool performanceMode;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.backgroundColor,
    this.border,
    this.performanceMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (performanceMode) {
      // Flat design for performance mode
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: padding,
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Gradient background widget
class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool performanceMode;

  const GradientBackground({
    super.key,
    required this.child,
    this.performanceMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (performanceMode) {
      // Flat background for performance mode
      return Container(
        height: double.infinity,
        color: Colors.grey[50],
        child: child,
      );
    }

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
