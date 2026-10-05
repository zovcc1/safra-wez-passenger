import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  final Function(String) onChanged;

  PhoneNumberFormatter({required this.onChanged});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (newText.length > 15) {
      // Limit the length to 11 digits
      return oldValue;
    }

    // Update the unformatted number
    onChanged(newText);

    // Apply the specific formatting
    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 3 || i == 6 || i == 10) {
        formattedText += ' ';
      }
      formattedText += newText[i];
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
