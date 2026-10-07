import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/presentation/util/widgets/photo_view.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class Utils {
  // The arrow glyphs are not mirrored by the bidi algorithm, so the arrow
  // between two governorates must follow the app language, not the glyph.
  static String get routeArrow =>
      AppTranslations.currentLang == "ar" ? "←" : "→";

  // Normalizes any arrow the server put inside a route name to the one that
  // points from origin to destination in the current reading direction.
  static String fixRouteArrows(String name) => name.replaceAllMapped(
    RegExp(r'\s*(→|←|->|<-)\s*'),
    (_) => " $routeArrow ",
  );

  // API may send name fields as a plain string or as {"ar": ..., "en": ...}
  static String parseLocalizedName(dynamic value) {
    if (value == null) return "";
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final lang = AppTranslations.currentLang;
      final fallback = map.values.where((v) => v != null).cast<dynamic>();
      final localized =
          map[lang] ??
          map["en"] ??
          map["ar"] ??
          (fallback.isEmpty ? null : fallback.first);
      return localized?.toString() ?? "";
    }
    return value.toString();
  }

  // Mirrors the server's plate_number normalization: Arabic-Indic digits to
  // ASCII, spaces/dashes stripped, so the client can predict plate_type
  // before submitting (national = 7 digits, governorate = 6 digits).
  static String normalizePlateNumber(String value) {
    const arabicIndicDigits = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
    ];
    var result = value;
    for (var i = 0; i < arabicIndicDigits.length; i++) {
      result = result.replaceAll(arabicIndicDigits[i], i.toString());
    }
    return result.replaceAll(RegExp(r'[\s-]'), '');
  }

  static bool isNationalPlateNumber(String plateNumber) =>
      normalizePlateNumber(plateNumber).length == 7;

  // Arabic Checker
  static bool isArabicText(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(text);
  }

  static bool intToBool(int value) {
    return value == 1 ? true : false;
  }

  static int boolToInt(bool value) {
    return value ? 1 : 0;
  }

  static bool isValidPositiveNonZeroNumber(String input) {
    final regex = RegExp(r'^(?:[1-9]\d*|[1-9]\d*\.\d+|0\.[1-9]\d*)$');
    return regex.hasMatch(input);
  }

  static bool? intToBoolOrNull(int? value) {
    if (value == null) return null;
    return value == 1 ? true : false;
  }

  static int? boolToIntOrNull(bool? value) {
    if (value == null) return null;
    return value ? 1 : 0;
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }

  // Date Picker
  static Future<DateTime?> selectDate(
    BuildContext context, {
    DateTime? firstDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime(1900, 8),
      lastDate: DateTime(2101),
    );
    return picked ?? DateTime.now();
  }

  // Time Picker
  static Future<DateTime?> selectTime({TimeOfDay? initialTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      DateTime dateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        picked.hour,
        picked.minute,
      );
      return dateTime;
    } else {
      return null;
    }
  }

  // Image Picker
  static Future<XFile?> imagePicker(
    ImageSource imageSource, {
    bool withCropper = true,
  }) async {
    final pickedImage = await ImagePicker().pickImage(source: imageSource);
    _printImageInfo(pickedImage);
    if (!withCropper) return pickedImage;
    final imageCropped = await _cropImage(pickedImage);
    _printImageInfo(imageCropped);
    return imageCropped;
  }

  static Future<XFile?> videoPicker(ImageSource source) async {
    final picker = ImagePicker();
    try {
      return await picker.pickVideo(source: source);
    } catch (e) {
      return null;
    }
  }

  static bool isVideo(XFile? file) {
    if (file == null) return false;
    final mimeType = lookupMimeType(file.path);
    return mimeType != null && mimeType.startsWith('video/');
  }

  static bool isImage(XFile? file) {
    if (file == null) return false;
    final mimeType = lookupMimeType(file.path);
    return mimeType != null && mimeType.startsWith('image/');
  }

  static Future<XFile?> _cropImage(XFile? image) async {
    if (image == null) return null;
    // final imageCropped = await ImageCropper().cropImage(
    //   sourcePath: image.path,
    //   compressQuality: 75,
    //   uiSettings: [
    //     AndroidUiSettings(
    //       initAspectRatio: CropAspectRatioPreset.square,
    //       toolbarTitle: 'Cropper',
    //       toolbarColor: ColorManager.colorPrimary,
    //       toolbarWidgetColor: ColorManager.colorWhite,
    //       aspectRatioPresets: [
    //         CropAspectRatioPreset.square,
    //         CropAspectRatioPreset.ratio7x5,
    //         CropAspectRatioPresetCustom(),
    //       ],
    //     ),
    //     IOSUiSettings(
    //       title: 'Cropper',
    //       aspectRatioPresets: [
    //         CropAspectRatioPreset.square,
    //         CropAspectRatioPreset.ratio7x5,
    //         CropAspectRatioPresetCustom(),
    //       ],
    //     ),
    //   ],
    // );
    // if (imageCropped == null) return null;
    return XFile(image.path);
  }

  static Future<void> _printImageInfo(XFile? imageFile) async {
    if (imageFile == null) return;
    try {
      // 1. Get file size
      final sizeInBytes = await imageFile.length();
      final sizeInKB = sizeInBytes / 1024;
      final sizeInMB = sizeInKB / 1024;

      // 2. Get file extension
      final extension = path.extension(imageFile.path).toLowerCase();

      // 3. Get other image info
      final name = path.basename(imageFile.path);
      final file = File(imageFile.path);
      final lastModified = await file.lastModified();

      // Print all information
      debugPrint('📄 Image Information:');
      debugPrint('----------------------');
      debugPrint('📌 Name: $name');
      debugPrint('📁 Extension: $extension');
      debugPrint('📏 Size:');
      debugPrint('  - ${sizeInBytes.toStringAsFixed(0)} bytes');
      debugPrint('  - ${sizeInKB.toStringAsFixed(2)} KB');
      debugPrint('  - ${sizeInMB.toStringAsFixed(2)} MB');
      debugPrint('⏱️ Last Modified: $lastModified');
      debugPrint('📍 Path: ${imageFile.path}');
      debugPrint('----------------------');
    } catch (e) {
      debugPrint('❌ Error getting image info: $e');
    }
  }

  // Multi Image Picker
  static Future<List<XFile>> multiImagePicker() async {
    List<XFile> files = [];
    final pickedImage = await ImagePicker().pickMultiImage();
    for (var image in pickedImage) {
      _printImageInfo(image);
      final imageCropped = await _cropImage(image);
      _printImageInfo(imageCropped);
      if (imageCropped != null) {
        files.add(imageCropped);
      }
    }
    return files;
  }

  // View Image
  static void viewImage({
    required String? path,
    required bool isNetwork,
    bool? isFile,
  }) {
    if (path == null) {
      return;
    }

    String safePath = path;
    Get.to(
      () => PhotoViewWidget(
        imagePath: safePath,
        isNetworkImage: isNetwork,
        isFile: isFile ?? true,
      ),
    );
  }

  static Future<List<PlatformFile>?> multiFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      return result.files;
    }
    return null;
  }

  static Future<PlatformFile?> filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      return result.files.first;
    }
    return null;
  }

  static Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (5, 7);

  @override
  String get name => '5x7';
}
