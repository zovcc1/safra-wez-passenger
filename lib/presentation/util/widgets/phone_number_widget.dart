import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/phone_number_formater.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class PhoneNumberInput extends StatelessWidget {
  const PhoneNumberInput({
    super.key,
    this.textEditingController,
    required this.onChanged,
    required this.countryCode,
    required this.readOnly,
    required this.hintText,
    this.minHeight = 55,
    this.validator,
    this.borderRadius = 16,
    this.focusNode,
    this.initialValue,
    this.title = '',
    this.initialCountyCode,
    required this.languageCode,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.fieldStyle = false,
  });

  final dynamic Function(String) onChanged;
  final TextEditingController? textEditingController;
  final RxString countryCode;
  final String hintText;
  final String? initialValue;
  final String? initialCountyCode;
  final String languageCode;
  final FocusNode? focusNode;
  final bool readOnly;
  final double minHeight;
  final double borderRadius;
  final String? Function(PhoneNumber?)? validator;
  final AutovalidateMode? autoValidateMode;
  final String title;

  /// true: نفس طراز حقول الرحلات (أبيض، حدّ رفيع، زوايا 10، بدون ثقل زائد).
  final bool fieldStyle;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: Get.textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            constraints: BoxConstraints(minHeight: minHeight),
            child: IntlPhoneField(
              autovalidateMode: autoValidateMode,
              focusNode: focusNode,
              readOnly: readOnly,
              languageCode: languageCode,
              validator: validator,
              controller: textEditingController,
              disableLengthCheck: true,
              initialCountryCode: initialCountyCode ?? 'SY',
              textAlign: AppTranslations.isArabic
                  ? TextAlign.end
                  : TextAlign.start,
              style: TextStyle(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w500,
                color: ColorManager.colorFontPrimary,
              ),
              initialValue: initialValue,
              textInputAction: TextInputAction.next,
              onCountryChanged: (Country country) {
                countryCode.value = "+${country.fullCountryCode}";
              },
              dropdownIcon: Icon(
                Icons.keyboard_arrow_down,
                size: fieldStyle ? 18 : 24,
              ),
              inputFormatters: [PhoneNumberFormatter(onChanged: onChanged)],
              decoration: InputDecoration(
                isDense: true,
                constraints: const BoxConstraints(minHeight: 40),
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: fieldStyle ? AppPadding.p12 : AppPadding.p16,
                  vertical: fieldStyle ? 10 : AppPadding.p12,
                ),
                filled: true,
                hintText: hintText,
                hintTextDirection: TextDirection.ltr,
                fillColor: ColorManager.colorWhite,
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Assets.icons.contactIcon.svg(
                    width: fieldStyle ? 22 : AppSize.s28,
                    colorFilter: fieldStyle
                        ? ColorFilter.mode(
                            ColorManager.colorPrimary,
                            BlendMode.srcIn,
                          )
                        : null,
                  ),
                ),
                prefixIconConstraints: fieldStyle
                    ? const BoxConstraints(minWidth: 0, minHeight: 0)
                    : null,
                suffixIconConstraints: fieldStyle
                    ? const BoxConstraints(minWidth: 0, minHeight: 0)
                    : null,
                enabledBorder: fieldStyle
                    ? _border(ColorManager.colorTextFieldEnabledBorder)
                    : null,
                focusedBorder: fieldStyle
                    ? _border(ColorManager.colorTextFieldFocusedBorder)
                    : null,
                errorBorder: fieldStyle
                    ? _border(ColorManager.colorTextFieldErrorBorder)
                    : null,
                focusedErrorBorder: fieldStyle
                    ? _border(ColorManager.colorTextFieldErrorBorder)
                    : null,
                border: fieldStyle
                    ? _border(ColorManager.colorTextFieldEnabledBorder)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
