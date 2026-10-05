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
      body: const Center(child: AppLogoWidget(width: 120, height: 120)),
    );
  }
}
