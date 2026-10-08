import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

/// تسمية صغيرة فوق الحقل بنفس أسلوب حقول البحث في تاب الرحلات.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: FontSize.s13,
          fontWeight: FontWeight.w500,
          color: ColorManager.colorDoveGray600,
        ),
      ),
    );
  }
}

/// حقل نصي بنفس طراز حقول الرحلات: تسمية فوقه، خلفية بيضاء، حدّ رفيع،
/// زوايا 10، ارتفاع 42، ونص w500.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    this.icon,
    this.suffixIcon = const SizedBox(),
    this.obscureText = false,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? icon;
  final Widget suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        CustomTextField(
          title: null,
          hint: hint,
          icon: icon,
          obscureText: obscureText,
          textEditingController: controller,
          textInputType: keyboardType,
          textInputAction: textInputAction,
          fillColor: ColorManager.colorWhite,
          borderRadius: 10,
          minHeight: 42,
          fontColor: ColorManager.colorFontPrimary,
          fontWeight: FontWeight.w500,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12,
            vertical: 10,
          ),
          validator: validator,
          suffixIcon: suffixIcon,
        ),
        const SizedBox(height: AppPadding.p12),
      ],
    );
  }
}
