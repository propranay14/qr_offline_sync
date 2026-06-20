import '../../data/model/candidate_sync_response_model.dart';

abstract class CandidateRepository {
  Future<CandidateSyncResponseModel> syncCandidates({
    required int lastCandidateId,
    required int limit,
  });
}