import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// مؤشر التحميل الوحيد في التطبيق.
///
/// - [AppLoader.new]: تحميل صفحة/قسم كامل (دائرة متلاشية).
/// - [AppLoader.dots]: تحميل صغير داخل عنصر أو "تحميل المزيد" (ثلاث نقاط،
///   نفس مؤشر الأزرار).
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 42, this.color}) : _dots = false;

  const AppLoader.dots({super.key, this.size = 20, this.color}) : _dots = true;

  final double size;
  final Color? color;
  final bool _dots;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? ColorManager.colorPrimary;
    return Center(
      child: _dots
          ? SpinKitThreeBounce(color: tint, size: size)
          : SpinKitFadingCircle(color: tint, size: size),
    );
  }
}

/// تحميل صفحة كاملة في منتصف المساحة المتاحة تمامًا، مع بقاء السحب للتحديث
/// (RefreshIndicator) يعمل لأن المحتوى قابل للتمرير.
class AppPageLoader extends StatelessWidget {
  const AppPageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: AppLoader())],
    );
  }
}
