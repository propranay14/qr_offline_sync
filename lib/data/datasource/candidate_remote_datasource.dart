import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../model/candidate_sync_request_model.dart';
import '../model/candidate_sync_response_model.dart';

class CandidateRemoteDatasource {
  final Dio dio = ApiClient.dio;

  Future<CandidateSyncResponseModel> syncCandidates({required int lastCandidateId, required int limit}) async {
    final response = await dio.post(
      ApiConstants.syncCandidates,
      data: CandidateSyncRequestModel(lastCandidateId: lastCandidateId, limit: limit).toJson(),
    );

    return CandidateSyncResponseModel.fromJson(response.data);
  }
}
