import 'dart:io';

import 'package:dio/dio.dart';

/// يُستخدم لإنشاء الطلب (create) وإعادة الإرسال (resubmit) والتعديل (PATCH).
/// بوضعي resubmit/edit تُرسل فقط الحقول التي لمسها المستخدم فعليًا — حقل لم
/// يُلمس لا يُرسل إطلاقًا (لا كقيمة فارغة)، لأن PATCH يعامل القيمة الفارغة
/// الصريحة كأمر مسح للإجابة المحفوظة سابقًا (راجع القسم 2 من الوثيقة).
class SubmitVisaRequestDto {
  final int? countryId;
  final int? templateId;
  final String? expectedPrice;
  final Map<int, String> values;
  final Map<int, File> files;

  const SubmitVisaRequestDto({
    this.countryId,
    this.templateId,
    this.expectedPrice,
    this.values = const {},
    this.files = const {},
  });

  Future<FormData> toFormData() async => FormData.fromMap({
    if (countryId != null) "country_id": countryId,
    if (templateId != null) "template_id": templateId,
    if (expectedPrice != null) "expected_price": expectedPrice,
    for (final e in values.entries) "values[${e.key}]": e.value,
    for (final e in files.entries)
      "files[${e.key}]": await MultipartFile.fromFile(
        e.value.path,
        filename: e.value.path.split('/').last,
      ),
  });
}
