import 'dart:io';
import 'package:dio/dio.dart';

extension FileMultipartExtension on File? {
  Future<MultipartFile?> toMultipartFile() async {
    if (this == null) return null;
    return await MultipartFile.fromFile(
      this!.path,
      filename: this!.path.split('/').last,
    );
  }
}
