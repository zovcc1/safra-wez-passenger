import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewWidget extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage;
  final bool isFile;

  const PhotoViewWidget({
    super.key,
    required this.imagePath,
    required this.isNetworkImage,
    this.isFile = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isNetworkImage) {
      return PhotoView(imageProvider: NetworkImage(imagePath));
    } else {
      if (isFile) {
        return PhotoView(imageProvider: FileImage(File(imagePath), scale: 0.7));
      } else {
        return PhotoView(imageProvider: AssetImage(imagePath));
      }
    }
  }
}
