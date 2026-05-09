import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Animated gradient sweep used for skeleton loaders.
/// Wrap one or more [ShimmerBox] / [ShimmerLine] in a [Shimmer] to sync them.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color base;
  final Color highlight;
  final Duration period;

  const Shimmer({
    super.key,
    required this.child,
    this.base = AppTheme.parchment,
    this.highlight = const Color(0xFFFFFCF1),
    this.period = const Duration(milliseconds: 1400),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final dx = (_c.value * 2 - 1) * rect.width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [widget.base, widget.highlight, widget.base],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideTransform(dx),
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideTransform extends GradientTransform {
  final double dx;
  const _SlideTransform(this.dx);
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.identity()..translate(dx, 0.0, 0.0);
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const ShimmerBox({super.key, this.width, this.height = 16, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.parchment,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double widthFactor;
  final double height;
  const ShimmerLine({super.key, this.widthFactor = 1.0, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: ShimmerBox(height: height, radius: 6),
    );
  }
}

/// Common skeleton for a list of cards.
class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final EdgeInsetsGeometry padding;
  const SkeletonList({
    super.key,
    this.count = 6,
    this.itemHeight = 86,
    this.padding = const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space2),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(count, (i) {
          return Padding(
            padding: padding,
            child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                color: AppTheme.parchment,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton for a horizontally-scrolling row of cards (carousel placeholder).
class SkeletonRow extends StatelessWidget {
  final int count;
  final double itemWidth;
  final double itemHeight;
  const SkeletonRow({super.key, this.count = 4, this.itemWidth = 160, this.itemHeight = 200});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SizedBox(
        height: itemHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Container(
            width: itemWidth,
            decoration: BoxDecoration(
              color: AppTheme.parchment,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
