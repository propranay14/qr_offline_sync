import '../../data/model/fetch_candidates_response_model.dart';

abstract class CandidateRepository {
  Future<FetchCandidatesResponseModel> fetchCandidates({required int limit, required String examId});
}
