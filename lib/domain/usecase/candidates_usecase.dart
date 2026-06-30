import '../../data/model/fetch_candidates_response_model.dart';
import '../repository/candidate_repository.dart';

class CandidatesUseCase {
  final CandidateRepository repository;

  CandidatesUseCase(this.repository);

  Future<FetchCandidatesResponseModel> call({required int limit, required String examId}) async {
    return await repository.fetchCandidates(limit: limit, examId: examId);
  }
}
