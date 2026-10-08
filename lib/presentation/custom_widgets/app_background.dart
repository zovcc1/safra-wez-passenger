import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// خلفية التطبيق المشتركة (الصورة + طبقة بيضاء شفافة فوقها).
///
/// عند ظهور لوحة المفاتيح يتقلّص جسم الـ Scaffold، فكانت الصورة تُقصّ ويظهر
/// أسود تحتها (لأن الـ Scaffold شفاف). لذلك تُمدَّد الصورة تحت منطقة
/// المفاتيح بحجم الشاشة الكامل بدل حجم الجسم المتقلّص.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  /// الطبقة فوق الصورة: بيضاء شفافة بالفاتح، وداكنة شبه معتمة بالداكن.
  static Color get overlayColor => ColorManager.isDark
      ? ColorManager.colorBackground.withValues(alpha: 0.92)
      : ColorManager.colorWhite.withValues(alpha: 0.75);

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return ColoredBox(
      color: ColorManager.colorBackground,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: -keyboard,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(
                    'assets/backgrounds/background_app.png',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppBackground.overlayColor,
                    BlendMode.srcOver,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
