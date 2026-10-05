import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  const CustomLinearProgressIndicator({
    super.key,
    this.valueColor,
    this.minHeight = 10,
    required this.maxValue,
    required this.currentValue,
  });

  final Color? valueColor;
  final double minHeight;
  final num maxValue;
  final num currentValue;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        // current / max
        value: maxValue == 0 ? 0 : currentValue / maxValue,
        minHeight: minHeight,
        backgroundColor: ColorManager.colorDoveGray100,
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? ColorManager.colorPrimary,
        ),
        borderRadius: BorderRadius.circular(AppSize.s10),
      ),
    );
  }
}
