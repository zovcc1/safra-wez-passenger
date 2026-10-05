import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_field_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_form_page/visa_request_form_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/utils.dart';

class VisaRequestFormPage extends GetView<VisaRequestFormPageController> {
  const VisaRequestFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      appBar: NormalAppBar(title: "visa_form_title".tr, backIcon: true),
      body: SafeArea(child: Obx(() => _body())),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state == LoadingState.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(title: "visa_form_error_title".tr),
          ),
        ],
      );
    }

    final form = controller.form.value!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12,
            vertical: AppPadding.p10,
          ),
          decoration: BoxDecoration(
            color: ColorManager.colorWhite,
            borderRadius: BorderRadius.circular(AppSize.s16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: AppSize.s20,
                color: ColorManager.colorPrimary,
              ),
              const SizedBox(width: AppPadding.p8),
              Text(
                "visa_form_price_label".tr,
                style: TextStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const Spacer(),
              Obx(
                () => Text(
                  controller.expectedPrice.value,
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.p12),
        for (final field in form.fields) ...[
          _FieldWidget(field: field),
          const SizedBox(height: AppPadding.p12),
        ],
        Obx(
          () => AppButton(
            text: "visa_form_submit_button".tr,
            radius: 12,
            minHeight: 42,
            loadingMode: controller.submitting.value,
            onPressed: controller.submit,
          ),
        ),
      ],
    );
  }
}

class _FieldWidget extends StatelessWidget {
  const _FieldWidget({required this.field});

  final VisaFieldModel field;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestFormPageController>();

    return Obx(() {
      final error = controller.fieldErrors.isEmpty
          ? null
          : controller.fieldError(field);

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12,
          vertical: AppPadding.p10,
        ),
        decoration: BoxDecoration(
          color: ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(AppSize.s16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    field.displayLabel,
                    style: TextStyle(
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
                if (field.required)
                  Text(
                    "*",
                    style: TextStyle(
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.colorError300,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppPadding.p8),
            if (field.type == "file")
              _FilePickerTile(field: field)
            else
              TextFormField(
                controller: controller.textControllers[field.fieldId],
                onChanged: (value) =>
                    controller.onTextChanged(field.fieldId, value),
                decoration: const InputDecoration(isDense: true),
              ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                error,
                style: TextStyle(
                  fontSize: FontSize.s11,
                  color: ColorManager.colorError300,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _FilePickerTile extends StatelessWidget {
  const _FilePickerTile({required this.field});

  final VisaFieldModel field;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestFormPageController>();
    final fileRx = controller.fileValues[field.fieldId];

    return Obx(() {
      final file = fileRx?.value;
      return InkWell(
        onTap: () async {
          final picked = await Utils.filePicker();
          if (picked?.path == null) return;
          controller.setFile(field.fieldId, File(picked!.path!));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12,
            vertical: AppPadding.p12,
          ),
          decoration: BoxDecoration(
            color: ColorManager.colorBackground,
            borderRadius: BorderRadius.circular(AppSize.s10),
          ),
          child: Row(
            children: [
              Icon(Icons.attach_file, color: ColorManager.colorGrey6, size: 18),
              const SizedBox(width: AppPadding.p8),
              Expanded(
                child: Text(
                  file == null
                      ? "visa_form_choose_file".tr
                      : file.path.split('/').last,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
