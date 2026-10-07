import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// انتقال الصفحات الموحّد: محور مشترك أفقي (shared axis) كما في Material —
/// الصفحة الداخلة تنزلق من جهة النهاية مع تلاشٍ، والصفحة التي تُغطّى تنزلق
/// قليلًا نحو البداية وتتلاشى. يتبع اتجاه الواجهة (عربي/إنجليزي) تلقائيًا،
/// والرجوع يعكس الحركة.
class AppPageTransition extends CustomTransition {
  static const double _distance = 36;

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // +1 في LTR (تدخل من اليمين)، و-1 في RTL (تدخل من اليسار).
    final dir = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;

    final enter = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final cover = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([enter, cover]),
      builder: (context, child) {
        final dx =
            (1 - enter.value) * _distance * dir -
            cover.value * _distance * 0.5 * dir;
        final opacity = enter.value * (1 - cover.value * 0.6);
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(dx, 0), child: child),
        );
      },
      child: child,
    );
  }
}
