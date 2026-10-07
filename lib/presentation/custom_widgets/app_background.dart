import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// خلفية التطبيق المشتركة (الصورة + طبقة بيضاء شفافة فوقها).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/backgrounds/background_app.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            ColorManager.colorWhite.withValues(alpha: 0.75),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: child,
    );
  }
}
