import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:url_launcher/url_launcher.dart';

extension WhatsAppChatExtension on String {
  Future<void> openWhatsAppChat({String? message}) async {
    final cleanedPhoneNumber = replaceAll(
      RegExp(r'\s+'),
      '',
    ).replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');

    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: cleanedPhoneNumber,
      queryParameters: message != null ? {'text': message} : null,
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      CustomToasts(
        message: "CouldNotOpenWhatsApp".tr,
        type: CustomToastType.error,
      ).show();
    }
  }
}
