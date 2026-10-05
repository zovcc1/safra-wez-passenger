import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

/// Centered "no data yet" state: icon, title, subtitle and an optional
/// call-to-action button. Deliberately card-less/borderless so it reads as
/// empty space rather than a clickable list row.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.s90,
            height: AppSize.s90,
            decoration: BoxDecoration(
              color: ColorManager.colorPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppSize.s40,
              color: ColorManager.colorPrimary,
            ),
          ),
          SizedBox(height: AppSize.s20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: ColorManager.colorDoveGray950,
            ),
          ),
          SizedBox(height: AppSize.s8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.sWidth * 0.08),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall?.copyWith(
                color: ColorManager.colorDoveGray600,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: AppSize.s24),
            AppButton(
              text: actionLabel,
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
              radius: 14,
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.s24,
                vertical: AppSize.s12,
              ),
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
