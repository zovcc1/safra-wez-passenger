import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:url_launcher/url_launcher.dart';

extension SmsExtension on String {
  Future<void> sendSms({String? message}) async {
    final cleanedPhoneNumber = replaceAll(
      RegExp(r'\s+'),
      '',
    ).replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanedPhoneNumber,
      queryParameters: message != null ? {'body': message} : null,
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      CustomToasts(
        message: "CouldNotLaunchSms".tr,
        type: CustomToastType.error,
      ).show();
    }
  }
}
