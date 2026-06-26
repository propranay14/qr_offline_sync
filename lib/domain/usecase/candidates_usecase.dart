import '../../data/model/fetch_candidates_response_model.dart';
import '../repository/candidate_repository.dart';

class CandidatesUseCase {
  final CandidateRepository repository;

  CandidatesUseCase(this.repository);

  Future<FetchCandidatesResponseModel> call({required int lastCandidateId, required int limit}) async {
    return await repository.fetchCandidates(lastCandidateId: lastCandidateId, limit: limit);
  }
}
