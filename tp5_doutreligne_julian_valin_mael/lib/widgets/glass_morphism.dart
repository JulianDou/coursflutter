import 'dart:ui';

import 'package:flutter/material.dart';

/// Glassmorphism glass container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
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

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/bg-market.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
