import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../model/fetch_candidates_request_model.dart';
import '../model/fetch_candidates_response_model.dart';

class CandidateRemoteDatasource {
  final Dio dio = ApiClient.dio;

  Future<FetchCandidatesResponseModel> fetchCandidates({required int limit, required String examId}) async {
    final response = await dio.post(
      ApiConstants.fetchCandidates,
      data: FetchCandidatesRequestModel(lastCandidateId: 0, limit: limit, examId: examId).toJson(),
    );

    return FetchCandidatesResponseModel.fromJson(response.data);
  }

  Future<bool> uploadCandidateBiometric(CandidateModel candidate, String examID) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    String deviceId = androidInfo.id;

    final formData = FormData.fromMap({
      "roll_number": candidate.rollNumber,
      "exam_id": examID,
      "operator_id": "DeepakB",
      "device_id": deviceId,
      "capture_time": candidate.captureTime,
      "remarks": candidate.remarks,
      if (candidate.photoPath != null) "photo": await MultipartFile.fromFile(candidate.photoPath!),
      if (candidate.fingerprintPath != null) "thumb": await MultipartFile.fromFile(candidate.fingerprintPath!),
      // if (candidate.fingerprintPath != null) "thumb": candidate.fingerprintPath!,
    });

    final response = await dio.post(
      ApiConstants.updateCandidateBiometric,
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );

    return response.data["success"] == true;
  }
}
