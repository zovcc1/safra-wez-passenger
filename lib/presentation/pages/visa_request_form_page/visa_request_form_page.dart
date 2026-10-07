import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_field_model.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_bottom_sheet.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_form_page/visa_request_form_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/utils.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class VisaRequestFormPage extends GetView<VisaRequestFormPageController> {
  const VisaRequestFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(title: "visa_form_title".tr, backIcon: true),
      body: AppBackground(child: SafeArea(child: Obx(() => _body()))),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return const AppLoader();
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
        if (controller.mode == VisaFormMode.create) ...[
          FadeSlideIn(
            child: _CardShell(
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ColorManager.colorPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: ColorManager.colorPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                      Money.format(controller.expectedPrice.value),
                      style: TextStyle(
                        fontSize: FontSize.s16,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppPadding.p8),
        ],
        FadeSlideIn(
          delay: const Duration(milliseconds: 70),
          child: _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: ColorManager.colorPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 18,
                        color: ColorManager.colorPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "visa_form_details_title".tr,
                      style: TextStyle(
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.p12),
                for (var i = 0; i < form.fields.length; i++) ...[
                  _FieldWidget(field: form.fields[i]),
                  if (i != form.fields.length - 1)
                    const SizedBox(height: AppPadding.p12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppPadding.p8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: Obx(
            () => AppButton(
              text: "visa_form_submit_button".tr,
              radius: 12,
              minHeight: 42,
              loadingMode: controller.submitting.value,
              onPressed: controller.submit,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppSize.s16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// شكل موحّد لكل حقول النموذج: خلفية رمادية فاتحة وزوايا 10 وإطار بلون التطبيق
/// عند التركيز أو بلون الخطأ عند وجوده.
InputDecoration _fieldDecoration({
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool hasError = false,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: ColorManager.colorWhite,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppPadding.p12,
      vertical: 12,
    ),
    enabledBorder: border(
      hasError
          ? ColorManager.colorError300
          : ColorManager.colorTextFieldEnabledBorder,
    ),
    focusedBorder: border(
      hasError ? ColorManager.colorError300 : ColorManager.colorPrimary,
    ),
    errorBorder: border(ColorManager.colorError300),
    focusedErrorBorder: border(ColorManager.colorError300),
    border: border(ColorManager.colorTextFieldEnabledBorder),
  );
}

TextStyle _fieldTextStyle() => TextStyle(
  fontFamily: AppTranslations.appFontFamily,
  fontSize: FontSize.s13,
  color: ColorManager.colorFontPrimary,
);

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
      final hasError = error != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  field.displayLabel,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorDoveGray600,
                  ),
                ),
              ),
              if (field.required)
                Text(
                  " *",
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorError300,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (field.type == "file")
            _FilePickerTile(field: field, hasError: hasError)
          else if (field.type == "select")
            _SelectField(field: field, hasError: hasError)
          else if (field.type == "date")
            _DateField(field: field, hasError: hasError)
          else
            TextFormField(
              controller: controller.textControllers[field.fieldId],
              onChanged: (value) =>
                  controller.onTextChanged(field.fieldId, value),
              style: _fieldTextStyle(),
              decoration: _fieldDecoration(hasError: hasError),
            ),
          if (hasError) ...[
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
      );
    });
  }
}

class _FilePickerTile extends StatelessWidget {
  const _FilePickerTile({required this.field, required this.hasError});

  final VisaFieldModel field;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestFormPageController>();
    final fileRx = controller.fileValues[field.fieldId];

    return Obx(() {
      final file = fileRx?.value;
      final picked = file != null;
      final existing = controller.existingDocuments[field.fieldId];
      final hasExisting = !picked && existing != null;
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final result = await Utils.filePicker();
          if (result?.path == null) return;
          controller.setFile(field.fieldId, File(result!.path!));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: picked
                ? ColorManager.colorPrimary.withValues(alpha: 0.08)
                : ColorManager.colorWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? ColorManager.colorError300
                  : (picked
                        ? ColorManager.colorPrimary
                        : ColorManager.colorTextFieldEnabledBorder),
            ),
          ),
          child: Row(
            children: [
              Icon(
                picked || hasExisting
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                color: picked || hasExisting
                    ? ColorManager.colorPrimary
                    : ColorManager.colorGrey6,
                size: 18,
              ),
              const SizedBox(width: AppPadding.p8),
              Expanded(
                child: Text(
                  picked
                      ? file.path.split(RegExp(r'[\\/]')).last
                      : hasExisting
                      ? existing.originalName
                      : "visa_form_choose_file".tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: picked ? FontWeight.w500 : FontWeight.normal,
                    color: picked || hasExisting
                        ? ColorManager.colorPrimary
                        : ColorManager.colorGrey6,
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

class _SelectField extends StatelessWidget {
  const _SelectField({required this.field, required this.hasError});

  final VisaFieldModel field;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestFormPageController>();
    final text = controller.textControllers[field.fieldId]!;

    // القيمة المرسلة هي نص الخيار بالإنكليزية (اتفاق مع فريق الأدمن).
    String valueOf(Map option) => "${option["en"] ?? option["ar"] ?? ""}";

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: text,
      builder: (context, value, _) {
        final selected = value.text;
        final selectedOption = field.options
            .where((o) => valueOf(o) == selected)
            .firstOrNull;
        final label = selectedOption == null
            ? null
            : Utils.parseLocalizedName(selectedOption);

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            showCustomBottomSheet(
              title: field.displayLabel,
              height: MediaQuery.of(context).size.height * 0.6,
              content: _OptionsList(
                options: [
                  for (final option in field.options)
                    (
                      value: valueOf(option),
                      label: Utils.parseLocalizedName(option),
                    ),
                ],
                selected: selected,
                onSelected: (v) => controller.setFieldText(field.fieldId, v),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: ColorManager.colorWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? ColorManager.colorError300
                    : ColorManager.colorTextFieldEnabledBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label ?? "visa_form_choose_option".tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _fieldTextStyle().copyWith(
                      color: label == null
                          ? ColorManager.colorGrey6
                          : ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: ColorManager.colorGrey6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionsList extends StatelessWidget {
  const _OptionsList({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<({String value, String label})> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppPadding.p16),
      itemCount: options.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.value == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            onSelected(option.value);
            Get.back();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorManager.colorPrimary.withValues(alpha: 0.08)
                  : ColorManager.colorWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? ColorManager.colorPrimary
                    : ColorManager.colorTextFieldEnabledBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: _fieldTextStyle().copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w500,
                      color: isSelected
                          ? ColorManager.colorPrimary
                          : ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: ColorManager.colorPrimary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.field, required this.hasError});

  final VisaFieldModel field;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestFormPageController>();
    final text = controller.textControllers[field.fieldId]!;
    return TextFormField(
      controller: text,
      readOnly: true,
      style: _fieldTextStyle(),
      decoration: _fieldDecoration(
        hasError: hasError,
        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          size: 18,
          color: ColorManager.colorGrey6,
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(text.text) ?? now,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year + 20),
        );
        if (picked == null) return;
        final mm = picked.month.toString().padLeft(2, '0');
        final dd = picked.day.toString().padLeft(2, '0');
        controller.setFieldText(field.fieldId, "${picked.year}-$mm-$dd");
      },
    );
  }
}
