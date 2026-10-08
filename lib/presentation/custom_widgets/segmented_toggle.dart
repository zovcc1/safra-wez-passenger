import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

/// مبدّل من خيارين (اللغة، الفاتح/الداكن...) بمؤشر منزلق.
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<(String, String)> options;
  final int selectedIndex;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: AlignmentDirectional(selectedIndex == 0 ? -1 : 1, 0),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorManager.colorWhite,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < options.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(options[i].$1),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: FontSize.s12,
                          fontWeight: i == selectedIndex
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: i == selectedIndex
                              ? ColorManager.colorPrimary
                              : ColorManager.colorGrey6,
                        ),
                        child: Text(options[i].$2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
