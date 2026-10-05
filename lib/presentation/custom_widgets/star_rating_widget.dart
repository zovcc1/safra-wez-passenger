import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// منتقي نجوم 1..5. مع [onChanged]=null يصبح عرضًا فقط (Read-only).
class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 32,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        final star = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: filled ? ColorManager.colorOrange : ColorManager.colorGrey6,
        );
        if (onChanged == null) return star;
        return InkResponse(
          onTap: () => onChanged!(i + 1),
          radius: size * 0.7,
          child: star,
        );
      }),
    );
  }
}
