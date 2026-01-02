import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable widget that implements a glassmorphic container with a frosted glass effect.
///
/// This widget uses [BackdropFilter] to blur the content behind it and applies a
/// semi-transparent gradient and border to simulate glass.
class GlassBox extends StatelessWidget {
  /// The child widget to display inside the glass box.
  final Widget child;

  /// The padding inside the glass box.
  final EdgeInsetsGeometry? padding;

  /// The border radius of the glass box corners. Defaults to 24.0.
  final double borderRadius;

  /// The amount of gaussian blur to apply to the background. Defaults to 15.0.
  final double blur;

  /// The opacity of the glass effect. Defaults to 0.1.
  /// Used for the gradient background.
  final double opacity;

  /// The color of the border around the glass box.
  /// Defaults to white with 0.12 opacity.
  final Color? borderColor;

  /// The colors for the linear gradient background.
  /// If null, a default white gradient based on [opacity] is used.
  final List<Color>? gradientColors;

  /// Creates a [GlassBox].
  const GlassBox({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.borderColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors ?? [
                Colors.white.withValues(alpha: opacity * 2),
                Colors.white.withValues(alpha: opacity),
              ],
            ),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
