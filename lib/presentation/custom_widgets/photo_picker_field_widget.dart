import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class PhotoPickerFieldWidget extends StatelessWidget {
  const PhotoPickerFieldWidget({
    super.key,
    required this.title,
    required this.imageFile,
    required this.onTap,
    this.errorText,
  });

  final String title;
  final File? imageFile;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: title,
            style: Get.textTheme.titleMedium,
            children: [
              TextSpan(
                text: ' *',
                style: Get.textTheme.titleMedium?.copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.s8),
        Center(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSize.s60),
            child: Container(
              width: AppSize.s90,
              height: AppSize.s90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.colorWhite,
                border: Border.all(
                  color: errorText != null
                      ? ColorManager.colorTextFieldErrorBorder
                      : ColorManager.colorTextFieldEnabledBorder,
                ),
                image: imageFile != null
                    ? DecorationImage(
                        image: FileImage(imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageFile == null
                  ? Center(
                      child: Assets.icons.cameraAddIcon.svg(
                        width: AppSize.s28,
                        colorFilter: ColorFilter.mode(
                          ColorManager.colorDoveGray600,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: AppSize.s4),
          Center(
            child: Text(
              errorText!,
              style: Get.textTheme.bodySmall?.copyWith(
                color: ColorManager.colorTextFieldErrorBorder,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
