import '../../data/model/candidate_sync_response_model.dart';
import '../repository/candidate_repository.dart';

class CandidatesSyncUseCase {
  final CandidateRepository repository;

  CandidatesSyncUseCase(this.repository);

  Future<CandidateSyncResponseModel> call({required int lastCandidateId, required int limit}) async {
    return await repository.syncCandidates(lastCandidateId: lastCandidateId, limit: limit);
  }
}
