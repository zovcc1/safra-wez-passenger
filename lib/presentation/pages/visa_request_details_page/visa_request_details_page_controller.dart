import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_document_model.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';
import 'package:safraa_passenger_app/data/repos/visa_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/utils.dart';

class VisaRequestDetailsPageController extends GetxController {
  final VisaRepo visaRepo = Get.find<VisaRepo>();

  late final int requestId;

  final loadingState = LoadingState.idle.obs;
  final Rxn<VisaRequestModel> request = Rxn<VisaRequestModel>();
  final withdrawing = false.obs;
  final downloadingDocumentId = RxnInt();
  final downloadProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    requestId = args is Map ? (args["requestId"] as int) : 0;
    _load();
  }

  Future<void> _load() async {
    loadingState.value = LoadingState.loading;
    final response = await visaRepo.details(requestId);
    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      return;
    }
    request.value = response.data;
    loadingState.value = LoadingState.doneWithData;
  }

  Future<void> retry() => _load();

  Future<void> withdraw() async {
    if (withdrawing.value) return;
    withdrawing.value = true;
    final response = await visaRepo.withdraw(requestId);
    withdrawing.value = false;

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    CustomToasts(
      message: "visa_details_withdraw_success".tr,
      type: CustomToastType.success,
    ).show();
    request.value = response.data;
  }

  Future<void> downloadDocument(VisaDocumentModel document) async {
    if (downloadingDocumentId.value != null) return;
    downloadingDocumentId.value = document.documentId;
    downloadProgress.value = 0;

    final file = await visaRepo.downloadDocument(
      requestId: requestId,
      documentId: document.documentId,
      fileName: document.originalName.isEmpty
          ? "visa_document_${document.documentId}"
          : document.originalName,
      progress: downloadProgress,
    );
    downloadingDocumentId.value = null;

    if (file == null) {
      CustomToasts(
        message: "visa_details_document_download_error".tr,
        type: CustomToastType.error,
      ).show();
      return;
    }

    await Utils.openFile(file.path);
  }
}
