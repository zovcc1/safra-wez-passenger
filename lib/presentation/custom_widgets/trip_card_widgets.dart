import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// أجزاء مشتركة لكاردات الرحلات والحجوزات (نفس التصميم والمسافات).

class TripCardShell extends StatelessWidget {
  const TripCardShell({
    super.key,
    required this.onTap,
    required this.child,
    this.borderColor,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: child,
          ),
        ),
      ),
    );
  }
}

class TripCardHeader extends StatelessWidget {
  const TripCardHeader({
    super.key,
    required this.title,
    required this.badge,
    required this.badgeColor,
    this.icon = Icons.alt_route_rounded,
  });

  final String title;
  final String badge;
  final Color badgeColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: ColorManager.colorPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: ColorManager.colorPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorFontPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }
}

class TripInfoBox extends StatelessWidget {
  const TripInfoBox({super.key, required this.start, this.end});

  final Widget start;
  final Widget? end;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: end == null
          ? start
          : IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: start),
                  VerticalDivider(
                    width: 20,
                    thickness: 1,
                    color: ColorManager.colorTextFieldEnabledBorder.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  Expanded(child: end!),
                ],
              ),
            ),
    );
  }
}

class TripInfoItem extends StatelessWidget {
  const TripInfoItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.weight = FontWeight.w500,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorManager.colorGrey6),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: weight,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: ColorManager.colorGrey6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class TripCardChip extends StatelessWidget {
  const TripCardChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TripCardFooter extends StatelessWidget {
  const TripCardFooter({super.key, required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 1,
          color: ColorManager.colorTextFieldEnabledBorder.withValues(
            alpha: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.colorPrimary,
                ),
              ),
            ),
            const TripCardArrow(),
          ],
        ),
      ],
    );
  }
}

class TripCardArrow extends StatelessWidget {
  const TripCardArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3F9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 12,
        color: ColorManager.colorGrey6,
      ),
    );
  }
}
