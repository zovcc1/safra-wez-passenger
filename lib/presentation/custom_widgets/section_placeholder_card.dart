import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class SectionPlaceholderCard extends StatelessWidget {
  const SectionPlaceholderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final Color accent = iconColor ?? ColorManager.colorPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.s16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSize.s16),
        decoration: BoxDecoration(
          color: ColorManager.colorWhite.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppSize.s16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppSize.s40,
              height: AppSize.s40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: AppSize.s20),
            ),
            SizedBox(width: AppSize.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: ColorManager.colorDoveGray950,
                    ),
                  ),
                  SizedBox(height: AppSize.s4),
                  Text(
                    subtitle,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: ColorManager.colorDoveGray600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppSize.s14,
                color: ColorManager.colorDoveGray600,
              ),
          ],
        ),
      ),
    );
  }
}
