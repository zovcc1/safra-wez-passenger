import 'package:get/get.dart';

/// عرض المبالغ بالليرة السورية: بدون فواصل وبدون كسور صفرية ("150000.00" →
/// "150000 ل.س"). المبالغ تصل من الخادم كنص ولا تُجمع/تُخزَّن كـ float؛ هذا
/// التحويل للعرض فقط.
class Money {
  Money._();

  /// الرقم منسَّقًا دون وحدة العملة.
  static String number(String? raw) {
    final text = raw?.trim() ?? "";
    final value = double.tryParse(text);
    if (value == null) return text;

    final negative = value < 0;
    final abs = value.abs();
    var fixed = abs.toStringAsFixed(2);
    if (fixed.endsWith(".00")) {
      fixed = fixed.substring(0, fixed.length - 3);
    } else if (fixed.endsWith("0")) {
      fixed = fixed.substring(0, fixed.length - 1);
    }

    return negative ? "-$fixed" : fixed;
  }

  /// المبلغ مع "ل.س" (أو SYP بالإنجليزية).
  static String format(String? raw) =>
      "trips_price_syp".trParams({"price": number(raw)});

  /// مبلغ حركة بإشارة (+/-) أمامه.
  static String signed(String sign, String? raw) =>
      "trips_price_syp".trParams({"price": "$sign${number(raw)}"});
}
