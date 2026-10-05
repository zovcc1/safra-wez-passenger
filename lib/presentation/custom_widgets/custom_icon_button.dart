import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
    this.iconColor,
    this.loadingMode = false,
  });

  final String iconPath;
  final void Function() onPressed;
  final Color? iconColor;
  final bool loadingMode;

  @override
  Widget build(BuildContext context) {
    final Color tint = iconColor ?? ColorManager.colorPrimary;

    return Container(
      margin: const EdgeInsetsDirectional.only(start: 10, end: AppPadding.p10),
      width: 40,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: tint,
          backgroundColor: tint.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.s14),
          ),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: loadingMode
            ? Center(
                child: SpinKitThreeBounce(color: tint, size: AppSize.s14),
              )
            : SvgPicture.asset(
                iconPath,
                width: AppSize.s18,
                height: AppSize.s18,
                colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
              ),
      ),
    );
  }
}
