import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class AppLogoWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const AppLogoWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/logo/LOGO_SAFRA.png",
      width: width ?? AppSize.s60,
      height: height ?? AppSize.s60,
      fit: BoxFit.contain,
    );
  }
}
