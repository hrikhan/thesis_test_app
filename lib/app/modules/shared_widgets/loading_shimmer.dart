import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
    this.shape = BoxShape.rectangle,
  });

  const LoadingShimmer.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color baseColor = isDark
        ? const Color(0xff2c2c2c)
        : const Color(0xffe0e0e0);

    final Color highlightColor = isDark
        ? const Color(0xff3a3a3a)
        : const Color(0xfff5f5f5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius)
              : null,
        ),
      ),
    );
  }
}
