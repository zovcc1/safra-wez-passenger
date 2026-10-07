import 'package:safraa_passenger_app/core/app/app_page_transition.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/forgot_password_page/forgot_password_page.dart';
import 'package:safraa_passenger_app/presentation/pages/booking_details_page/booking_details_page.dart';
import 'package:safraa_passenger_app/presentation/pages/booking_details_page/booking_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/change_password_page/change_password_page.dart';
import 'package:safraa_passenger_app/presentation/pages/change_password_page/change_password_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/complaint_details_page/complaint_details_page.dart';
import 'package:safraa_passenger_app/presentation/pages/complaint_details_page/complaint_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/complaints_page/complaints_page.dart';
import 'package:safraa_passenger_app/presentation/pages/complaints_page/complaints_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/file_complaint_page/file_complaint_page.dart';
import 'package:safraa_passenger_app/presentation/pages/file_complaint_page/file_complaint_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/create_booking_page/create_booking_page.dart';
import 'package:safraa_passenger_app/presentation/pages/create_booking_page/create_booking_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/forgot_password_page/forgot_password_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/login_page/login_page.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/login_page/login_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/register_page/register_page.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/register_page/register_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/reset_password_page/reset_password_page.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/reset_password_page/reset_password_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/verify_otp_page/verify_otp_page.dart';
import 'package:safraa_passenger_app/presentation/pages/auth/verify_otp_page/verify_otp_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/main_page/main_binding.dart';
import 'package:safraa_passenger_app/presentation/pages/main_page/main_page.dart';
import 'package:safraa_passenger_app/presentation/pages/notification_settings_page/notification_settings_page.dart';
import 'package:safraa_passenger_app/presentation/pages/notification_settings_page/notification_settings_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/notifications_page/notifications_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/payment_request_details_page/payment_request_details_page.dart';
import 'package:safraa_passenger_app/presentation/pages/payment_request_details_page/payment_request_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/pickup_picker_page/pickup_picker_page.dart';
import 'package:safraa_passenger_app/presentation/pages/pickup_picker_page/pickup_picker_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/tracking_page/tracking_page.dart';
import 'package:safraa_passenger_app/presentation/pages/tracking_page/tracking_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/notifications_page/notifications_page.dart';
import 'package:safraa_passenger_app/presentation/pages/onboarding_page/onboarding_page.dart';
import 'package:safraa_passenger_app/presentation/pages/onboarding_page/onboarding_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/splash_page/splash_page.dart';
import 'package:safraa_passenger_app/presentation/pages/splash_page/splash_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/wallet_page/wallet_page.dart';
import 'package:safraa_passenger_app/presentation/pages/wallet_page/wallet_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_countries_page/visa_countries_page.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_countries_page/visa_countries_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_details_page/visa_request_details_page.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_details_page/visa_request_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_form_page/visa_request_form_page.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_form_page/visa_request_form_page_controller.dart';

abstract class NavigationManager {
  static final List<GetPage> _pages = <GetPage>[
    GetPage(
      name: AppRoutes.splashRoute,
      page: () => const SplashPage(),
      binding: BindingsBuilder.put(() => SplashPageController()),
    ),
    GetPage(
      name: AppRoutes.onboardingRoute,
      page: () => const OnboardingPage(),
      binding: BindingsBuilder.put(() => OnboardingPageController()),
    ),
    GetPage(
      name: AppRoutes.loginRoute,
      page: () => const LoginPage(),
      binding: BindingsBuilder.put(() => LoginPageController()),
    ),
    GetPage(
      name: AppRoutes.registerRoute,
      page: () => const RegisterPage(),
      binding: BindingsBuilder.put(() => RegisterPageController()),
    ),
    GetPage(
      name: AppRoutes.verifyOtpRoute,
      page: () => const VerifyOtpPage(),
      binding: BindingsBuilder.put(() => VerifyOtpPageController()),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordRoute,
      page: () => const ForgotPasswordPage(),
      binding: BindingsBuilder.put(() => ForgotPasswordPageController()),
    ),
    GetPage(
      name: AppRoutes.resetPasswordRoute,
      page: () => const ResetPasswordPage(),
      binding: BindingsBuilder.put(() => ResetPasswordPageController()),
    ),
    GetPage(
      name: AppRoutes.mainRoute,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingDetailsRoute,
      page: () => const BookingDetailsPage(),
      binding: BindingsBuilder.put(() => BookingDetailsPageController()),
    ),
    GetPage(
      name: AppRoutes.createBookingRoute,
      page: () => const CreateBookingPage(),
      binding: BindingsBuilder.put(() => CreateBookingPageController()),
    ),
    GetPage(
      name: AppRoutes.changePasswordRoute,
      page: () => const ChangePasswordPage(),
      binding: BindingsBuilder.put(() => ChangePasswordPageController()),
    ),
    GetPage(
      name: AppRoutes.notificationsRoute,
      page: () => const NotificationsPage(),
      binding: BindingsBuilder.put(() => NotificationsPageController()),
    ),
    GetPage(
      name: AppRoutes.notificationSettingsRoute,
      page: () => const NotificationSettingsPage(),
      binding: BindingsBuilder.put(() => NotificationSettingsPageController()),
    ),
    GetPage(
      name: AppRoutes.pickupPickerRoute,
      page: () => const PickupPickerPage(),
      binding: BindingsBuilder.put(() => PickupPickerPageController()),
    ),
    GetPage(
      name: AppRoutes.trackingRoute,
      page: () => const TrackingPage(),
      binding: BindingsBuilder.put(() => TrackingPageController()),
    ),
    GetPage(
      name: AppRoutes.paymentRequestDetailsRoute,
      page: () => const PaymentRequestDetailsPage(),
      binding: BindingsBuilder.put(() => PaymentRequestDetailsPageController()),
    ),
    GetPage(
      name: AppRoutes.visaCountriesRoute,
      page: () => const VisaCountriesPage(),
      binding: BindingsBuilder.put(() => VisaCountriesPageController()),
    ),
    GetPage(
      name: AppRoutes.visaRequestFormRoute,
      page: () => const VisaRequestFormPage(),
      binding: BindingsBuilder.put(() => VisaRequestFormPageController()),
    ),
    GetPage(
      name: AppRoutes.visaRequestDetailsRoute,
      page: () => const VisaRequestDetailsPage(),
      binding: BindingsBuilder.put(() => VisaRequestDetailsPageController()),
    ),
    GetPage(
      name: AppRoutes.walletRoute,
      page: () => const WalletPage(),
      binding: BindingsBuilder.put(() => WalletPageController()),
    ),
    GetPage(
      name: AppRoutes.complaintsRoute,
      page: () => const ComplaintsPage(),
      binding: BindingsBuilder.put(() => ComplaintsPageController()),
    ),
    GetPage(
      name: AppRoutes.fileComplaintRoute,
      page: () => const FileComplaintPage(),
      binding: BindingsBuilder.put(() => FileComplaintPageController()),
    ),
    GetPage(
      name: AppRoutes.complaintDetailsRoute,
      page: () => const ComplaintDetailsPage(),
      binding: BindingsBuilder.put(() => ComplaintDetailsPageController()),
    ),
  ];

  /// كل الصفحات بانتقال التطبيق الموحّد ([AppPageTransition]).
  static final List<GetPage> getPages = [
    for (final page in _pages) page.copy(customTransition: AppPageTransition()),
  ];
}

abstract class AppRoutes {
  static const String splashRoute = "/";
  static const String onboardingRoute = "/onboardingRoute";
  static const String loginRoute = "/login";
  static const String registerRoute = "/register";
  static const String verifyOtpRoute = "/verifyOtp";
  static const String forgotPasswordRoute = "/forgotPassword";
  static const String resetPasswordRoute = "/resetPassword";
  static const String mainRoute = "/main";
  static const String bookingDetailsRoute = "/bookingDetails";
  static const String createBookingRoute = "/createBooking";
  static const String changePasswordRoute = "/changePassword";
  static const String notificationsRoute = "/notifications";
  static const String notificationSettingsRoute = "/notificationSettings";
  static const String pickupPickerRoute = "/pickupPicker";
  static const String trackingRoute = "/tracking";
  static const String paymentRequestDetailsRoute = "/paymentRequestDetails";
  static const String visaCountriesRoute = "/visaCountries";
  static const String visaRequestFormRoute = "/visaRequestForm";
  static const String visaRequestDetailsRoute = "/visaRequestDetails";
  static const String walletRoute = "/wallet";
  static const String complaintsRoute = "/complaints";
  static const String fileComplaintRoute = "/fileComplaint";
  static const String complaintDetailsRoute = "/complaintDetails";
}
