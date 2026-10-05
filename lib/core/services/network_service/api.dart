abstract class Api {
  /// Authentication
  static const String login = "auth/login";
  static const String register = "auth/register";
  static const String verifyOtp = "auth/verify-otp";
  static const String resendOtp = "auth/resend-otp";
  static const String forgotPassword = "auth/forgot-password";
  static const String resetPassword = "auth/reset-password";
  static const String changePassword = "auth/change-password";
  static const String logout = "auth/logout";
  static const String logoutAll = "auth/logout-all";
  static const String me = "auth/me";
  static const String refresh = "auth/refresh";
  static const String pushToken = "auth/push-token";

  /// Reference data
  static const String governorates = "reference/governorates";
  static const String complaintCategories = "reference/complaint-categories";

  /// Trips
  static const String tripsSearch = "passenger/trips/search";
  static String tripSeats(int tripId) => "passenger/trips/$tripId/seats";

  /// Bookings
  static const String bookings = "passenger/bookings";
  static String bookingDetails(int bookingId) =>
      "passenger/bookings/$bookingId";
  static String bookingRating(int bookingId) =>
      "passenger/bookings/$bookingId/rating";

  static String bookingPickupPoint(int bookingId) =>
      "passenger/bookings/$bookingId/pickup-point";
  static String bookingTracking(int bookingId) =>
      "passenger/bookings/$bookingId/tracking";

  /// Payment requests
  static const String paymentRequests = "passenger/payment-requests";
  static String paymentRequestDetails(int id) =>
      "passenger/payment-requests/$id";
  static String paymentRequestApprove(int id) =>
      "passenger/payment-requests/$id/approve";
  static String paymentRequestReject(int id) =>
      "passenger/payment-requests/$id/reject";

  /// Notifications
  static const String notifications = "passenger/notifications";
  static String notificationRead(int id) => "passenger/notifications/$id/read";
  static const String notificationPreferences = "auth/notification-preferences";

  /// Complaints
  static const String complaints = "passenger/complaints";
  static String complaintDetails(int id) => "passenger/complaints/$id";
  static String complaintReplies(int id) => "passenger/complaints/$id/replies";

  /// Wallet
  static const String wallet = "passenger/wallet";
  static const String walletTransactions = "passenger/wallet/transactions";

  /// Visa
  static const String visaCountries = "reference/visa/countries";
  static String visaCountryForm(int countryId) =>
      "reference/visa/countries/$countryId/form";
  static const String visaRequests = "passenger/visa-requests";
  static String visaRequestDetails(int id) => "passenger/visa-requests/$id";
  static String visaRequestResubmit(int id) =>
      "passenger/visa-requests/$id/resubmit";
  static String visaRequestWithdraw(int id) =>
      "passenger/visa-requests/$id/withdraw";
  static String visaRequestDocument(int id, int documentId) =>
      "passenger/visa-requests/$id/documents/$documentId";
}
