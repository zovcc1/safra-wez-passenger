import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.child, this.color, this.padding});

  final Color? color;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sWidth,
      padding: padding ?? EdgeInsets.all(AppSize.sWidth * 0.035),
      decoration: BoxDecoration(
        color: color ?? ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppSize.s8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
