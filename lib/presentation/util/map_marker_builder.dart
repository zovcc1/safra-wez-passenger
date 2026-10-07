import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// يرسم ماركر مخصص: دائرة بأيقونة، وفوقها بطاقة نصية تعبّر عنه (سائق / أنت).
/// الصورة متناظرة رأسيًا (مساحة شفافة أسفل الدائرة بقدر ارتفاع البطاقة) فيكون
/// مركز الدائرة = مركز الصورة، وتكفي anchor (0.5, 0.5).
abstract class MapMarkerBuilder {
  static const double _scale = 3; // pixel ratio
  static const double _circle = 44;
  static const double _labelHeight = 24;
  static const double _gap = 4;

  static Future<BitmapDescriptor> build({
    required IconData icon,
    required String label,
    required Color color,
  }) async {
    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelWidth = labelPainter.width + 20;
    final width = labelWidth > _circle ? labelWidth : _circle;
    const sideHeight = _labelHeight + _gap;
    const height = _circle + sideHeight * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(_scale);

    // البطاقة
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((width - labelWidth) / 2, 0, labelWidth, _labelHeight),
      const Radius.circular(12),
    );
    canvas.drawRRect(labelRect, Paint()..color = color);
    labelPainter.paint(
      canvas,
      Offset(
        (width - labelPainter.width) / 2,
        (_labelHeight - labelPainter.height) / 2,
      ),
    );

    // الدائرة
    final center = Offset(width / 2, sideHeight + _circle / 2);
    canvas.drawCircle(
      center,
      _circle / 2,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, _circle / 2, Paint()..color = Colors.white);
    canvas.drawCircle(center, _circle / 2 - 3, Paint()..color = color);

    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
    )..layout();
    iconPainter.paint(
      canvas,
      center - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );

    final image = await recorder.endRecording().toImage(
      (width * _scale).ceil(),
      (height * _scale).ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: _scale,
    );
  }
}
