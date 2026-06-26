import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../model/fetch_candidates_request_model.dart';
import '../model/fetch_candidates_response_model.dart';

class CandidateRemoteDatasource {
  final Dio dio = ApiClient.dio;

  Future<FetchCandidatesResponseModel> fetchCandidates({required int lastCandidateId, required int limit}) async {
    final response = await dio.post(
      ApiConstants.fetchCandidates,
      data: FetchCandidatesRequestModel(lastCandidateId: lastCandidateId, limit: limit).toJson(),
    );

    return FetchCandidatesResponseModel.fromJson(response.data);
  }
}
