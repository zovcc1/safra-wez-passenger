/// تصنيف شكوى — اللغتان تعودان معًا من الـ API، فنختار حسب لغة التطبيق.
class ComplaintCategoryModel {
  final String key;
  final String ar;
  final String en;

  const ComplaintCategoryModel({
    required this.key,
    required this.ar,
    required this.en,
  });

  String labelFor(String lang) => lang == "ar" ? ar : en;

  factory ComplaintCategoryModel.fromJson(Map<String, dynamic> json) =>
      ComplaintCategoryModel(
        key: json["key"]?.toString() ?? "",
        ar: json["ar"]?.toString() ?? "",
        en: json["en"]?.toString() ?? "",
      );
}
