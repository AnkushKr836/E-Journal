import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? customColor;
  final Color? customBorderColor;
  final VoidCallback? onTap;
  final bool glow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 20,
    this.blur = 16,
    this.customColor,
    this.customBorderColor,
    this.onTap,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = customColor ??
        (isDark
            ? const Color(0xFF0C1322).withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.70));

    final borderColor = customBorderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.85));

    final glowShadow = glow
        ? [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ]
        : [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFF94A3B8).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ];

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: glowShadow,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.08),
                        const Color(0xFF1E293B).withValues(alpha: 0.40),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        const Color(0xFFE2E8F0).withValues(alpha: 0.35),
                      ],
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
