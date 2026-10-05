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

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              dropdownIcon: const Icon(Icons.keyboard_arrow_down),
              inputFormatters: [PhoneNumberFormatter(onChanged: onChanged)],
              decoration: InputDecoration(
                isDense: true,
                constraints: const BoxConstraints(minHeight: 40),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p16,
                  vertical: AppPadding.p12,
                ),
                filled: true,
                hintText: hintText,
                hintTextDirection: TextDirection.ltr,
                fillColor: ColorManager.colorWhite,
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Assets.icons.contactIcon.svg(width: AppSize.s28),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
