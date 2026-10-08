import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_logo_widget.dart';
import 'package:safraa_passenger_app/presentation/pages/splash_page/splash_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

class SplashPage extends GetView<SplashPageController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorSplashBackground,
      body: const Center(child: _AnimatedLogo()),
    );
  }
}

/// ظهور اللوغو بتكبير مع ارتداد وتلاشي، ثم نبض خفيف مستمر حتى الانتقال.
class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.55,
    end: 1,
  ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutBack));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );
  late final Animation<double> _breathe = Tween<double>(
    begin: 1,
    end: 1.06,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _intro.forward().whenComplete(() {
      if (mounted) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: ScaleTransition(
          scale: _breathe,
          child: const AppLogoWidget(width: 120, height: 120),
        ),
      ),
    );
  }
}
