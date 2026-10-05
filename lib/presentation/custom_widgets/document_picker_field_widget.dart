import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class DocumentPickerFieldWidget extends StatelessWidget {
  const DocumentPickerFieldWidget({
    super.key,
    required this.title,
    required this.file,
    required this.onTap,
    this.errorText,
  });

  final String title;
  final PlatformFile? file;
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSize.s10),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 55),
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.s14,
              vertical: AppSize.s14,
            ),
            decoration: BoxDecoration(
              color: ColorManager.colorWhite,
              borderRadius: BorderRadius.circular(AppSize.s10),
              border: Border.all(
                color: errorText != null
                    ? ColorManager.colorTextFieldErrorBorder
                    : ColorManager.colorTextFieldEnabledBorder,
              ),
            ),
            child: Row(
              children: [
                Assets.icons.folderIcon.svg(
                  width: AppSize.s20,
                  colorFilter: ColorFilter.mode(
                    ColorManager.colorDoveGray600,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: AppSize.s10),
                Expanded(
                  child: Text(
                    file?.name ?? "UploadFile".tr,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: file == null
                          ? ColorManager.colorDoveGray600
                          : null,
                    ),
                  ),
                ),
                Assets.icons.uploadIcon.svg(
                  width: AppSize.s18,
                  colorFilter: ColorFilter.mode(
                    ColorManager.colorDoveGray600,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: AppSize.s4),
          Text(
            errorText!,
            style: Get.textTheme.bodySmall?.copyWith(
              color: ColorManager.colorTextFieldErrorBorder,
            ),
          ),
        ],
      ],
    );
  }
}
