import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// A standard surface card with hairline border and a tiny shadow.
/// Use for static content tiles. For tappable cards prefer [QalaamTappableCard].
class QalaamCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? radius;
  final bool elevated;
  final BoxBorder? border;

  const QalaamCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.radius,
    this.elevated = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppTheme.radiusLg;
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppTheme.space5),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(r),
        border: border ?? Border.all(color: AppTheme.borderHair, width: 1),
        boxShadow: elevated ? AppTheme.shadowMd : AppTheme.shadowSm,
      ),
      child: child,
    );
  }
}

class QalaamTappableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? radius;

  const QalaamTappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppTheme.radiusLg;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: color ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          splashColor: AppTheme.primaryGreen.withOpacity(0.08),
          highlightColor: AppTheme.primaryGreen.withOpacity(0.04),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.space5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r),
              border: Border.all(color: AppTheme.borderHair, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
