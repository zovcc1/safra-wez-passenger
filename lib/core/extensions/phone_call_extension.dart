import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

extension PhoneCallExtension on String {
  Future<void> makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: this);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      CustomToasts(
        message: "CouldNotLaunchPhoneCall".tr,
        type: CustomToastType.error,
      ).show();
    }
  }
}
