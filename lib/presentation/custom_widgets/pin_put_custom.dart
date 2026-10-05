import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class PinPutCustom extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onCompleted;
  final String? Function(String?)? validator;
  final AutovalidateMode? autoValidateMode;

  const PinPutCustom({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.validator,
    this.autoValidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          controller: controller,
          length: 6,
          separatorBuilder: (index) => const SizedBox(width: 12),
          defaultPinTheme: PinTheme(
            height: AppSize.sHeight * 0.06,
            width: AppSize.sWidth * 0.1,
            decoration: BoxDecoration(
              color: ColorManager.colorWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorManager.colorGrey7),
            ),
          ),
          focusedPinTheme: PinTheme(
            height: AppSize.sHeight * 0.06,
            width: AppSize.sWidth * 0.1,
            textStyle: Get.textTheme.bodyMedium,
            decoration: BoxDecoration(
              color: ColorManager.colorGreen3.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorManager.colorGreen3),
            ),
          ),
          submittedPinTheme: PinTheme(
            height: AppSize.sHeight * 0.06,
            width: AppSize.sWidth * 0.1,
            textStyle: Get.textTheme.bodyMedium,
            decoration: BoxDecoration(
              color: ColorManager.colorGreen3.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorManager.colorGreen3),
            ),
          ),
          errorPinTheme: PinTheme(
            height: AppSize.sHeight * 0.06,
            width: AppSize.sWidth * 0.1,
            textStyle: Get.textTheme.bodyMedium,
            decoration: BoxDecoration(
              color: ColorManager.colorPrimary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorManager.colorError),
            ),
          ),
          onCompleted: onCompleted,
        ),
      ),
    );
  }
}
