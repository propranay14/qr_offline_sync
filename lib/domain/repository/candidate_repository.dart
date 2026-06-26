import '../../data/model/fetch_candidates_response_model.dart';

abstract class CandidateRepository {
  Future<FetchCandidatesResponseModel> fetchCandidates({required int lastCandidateId, required int limit});

  Future<void> syncAllCandidates({required int lastCandidateId});
}
