import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateConverter {
  static DateTime? stringToDate(String? dateString, {String? format}) {
    if (dateString == null) {
      return null;
    }

    DateTime utcTime = DateFormat(
      format ?? "yyyy-MM-ddTHH:mm:ss",
    ).parse(dateString, true);
    DateTime localTime = utcTime.toLocal();
    return localTime;
  }

  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(":");
    if (parts.length != 2) {
      throw FormatException("Invalid time format. Expected HH:mm");
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      throw FormatException("Invalid numbers in time string");
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String dateUTCToString(
    DateTime? date, {
    String format = "dd/MM/yyyy",
  }) {
    if (date == null) return "-------";
    return DateFormat(format).format(date);
  }

  static String dateToStringAR(DateTime? date) {
    if (date == null) return "-------";
    final month = DateFormat("MMMM", "ar").format(date);
    final year = DateFormat("yyyy").format(date);
    final day = DateFormat("d").format(date);
    return "$day $month $year";
  }

  static String timeUTCToString(DateTime? time, {format = "HH:mm"}) {
    if (time == null) return "-------";
    return DateFormat(format).format(time);
  }

  static String dayWithTimeUTCToString(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return "Today ${DateFormat('HH:mm').format(timestamp)}";
    } else if (messageDate == yesterday) {
      return "Yesterday ${DateFormat('HH:mm').format(timestamp)}";
    } else {
      return DateFormat(
        'EEE d MMM, yyyy HH:mm',
      ).format(timestamp); // Use full date
    }
  }

  static String timeDifference(DateTime startDateTime, DateTime endDateTime) {
    Duration difference = endDateTime.difference(startDateTime.toLocal());
    if (difference.inDays > 2) {
      var formattedDate = DateConverter.dateUTCToString(
        startDateTime,
        format: "d.M.yyyy",
      );
      var formattedTime = DateConverter.timeUTCToString(startDateTime);

      return "$formattedDate ${'at'.tr} $formattedTime";
    }
    if (difference.inDays > 1) {
      var formattedTime = DateConverter.timeUTCToString(startDateTime);
      return "${'yesterday_at'.tr} $formattedTime";
    }
    if (difference.inDays > 0) {
      return "${difference.inDays} ${'day'.tr}";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${'hour'.tr}";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${'minute'.tr}";
    } else {
      return "just_now".tr;
    }
  }

  static DateTime toDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }
}
