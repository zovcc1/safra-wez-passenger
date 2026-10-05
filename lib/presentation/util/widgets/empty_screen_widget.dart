import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class EmptyScreenWidget extends StatelessWidget {
  const EmptyScreenWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.imageSize = 88,
    this.isSvg = false,
  });

  final String image;
  final String title;
  final String subtitle;
  final double imageSize;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: isSvg
                  ? SvgPicture.asset(image, fit: BoxFit.fitWidth)
                  : Image.asset(image, fit: BoxFit.fitWidth),
            ),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: ColorManager.colorGrey4),
            ),
          ],
        ),
      ),
    );
  }
}
