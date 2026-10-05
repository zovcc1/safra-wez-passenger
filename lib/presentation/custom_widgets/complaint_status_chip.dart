import 'package:flutter/material.dart';
import 'package:safraa_passenger_app/presentation/util/complaint_display.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class ComplaintStatusChip extends StatelessWidget {
  const ComplaintStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final display = ComplaintStatusDisplay.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: display.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: display.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            display.label,
            style: TextStyle(
              fontSize: FontSize.s10_5,
              fontWeight: FontWeight.bold,
              color: display.color,
            ),
          ),
        ],
      ),
    );
  }
}
