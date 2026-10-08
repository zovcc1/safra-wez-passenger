import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

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
        const TripCardDivider(),
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

/// فاصل متلاشي الأطراف بدل خط كامل حاد.
class TripCardDivider extends StatelessWidget {
  const TripCardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final line = ColorManager.colorTextFieldEnabledBorder;
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            line.withValues(alpha: 0),
            line.withValues(alpha: 0.7),
            line.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class TripStripCell {
  const TripStripCell({required this.icon, required this.text, this.flex = 1});

  final IconData icon;
  final String text;
  final int flex;
}

/// شريط معلومات مدمج: خلايا متجاورة (أيقونة + نص صغير) بينها فواصل رفيعة.
class TripInfoStrip extends StatelessWidget {
  const TripInfoStrip({super.key, required this.cells});

  final List<TripStripCell> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: ColorManager.colorTextFieldEnabledBorder.withValues(
                    alpha: 0.6,
                  ),
                ),
              Expanded(
                flex: cells[i].flex,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cells[i].icon,
                      size: 13,
                      color: ColorManager.colorGrey6,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        cells[i].text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: FontSize.s10_5,
                          color: ColorManager.colorDoveGray600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// كارد مدمج من سطرين (عنوان + شارة، ثم تفاصيل + سعر) يوحّد شكل الحجوزات
/// وطلبات الدفع والتأشيرات. [extra] سطر اختياري تحت السطرين.
class CompactTripCard extends StatelessWidget {
  const CompactTripCard({
    super.key,
    required this.onTap,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.details,
    required this.price,
    this.priceVoided = false,
    this.extra,
  });

  final VoidCallback? onTap;
  final String title;
  final String badge;
  final Color badgeColor;
  final List<InlineSpan> details;
  final String price;

  /// السعر مشطوب ورمادي (حجز ملغى أو لم يحضر).
  final bool priceVoided;
  final Widget? extra;

  /// نص الشارة بدرجة أعمق من خلفيتها لتباين أوضح.
  static Color deepen(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0)).toColor();
  }

  /// جزء بارز (الوقت مثلًا) داخل سطر التفاصيل.
  static TextSpan strong(String text) => TextSpan(
    text: text,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      color: ColorManager.colorFontPrimary,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final grey = ColorManager.colorGrey6;
    return TripCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w600,
                    color: deepen(badgeColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: details),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: FontSize.s14, color: grey),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                price,
                style: TextStyle(
                  fontSize: FontSize.s16,
                  fontWeight: FontWeight.w700,
                  color: priceVoided ? grey : ColorManager.colorFontPrimary,
                  decoration: priceVoided ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          if (extra != null) ...[const SizedBox(height: 6), extra!],
        ],
      ),
    );
  }
}
