import 'package:qr_offline_sync/data/datasource/candidate_remote_datasource.dart';

import '../../domain/repository/candidate_repository.dart';
import '../local_db/local_db.dart';
import '../model/fetch_candidates_response_model.dart';

class CandidateRepositoryImpl implements CandidateRepository {
  final CandidateRemoteDatasource remoteDataSource;
  final LocalDb localDb;

  CandidateRepositoryImpl(this.remoteDataSource, this.localDb);

  @override
  Future<FetchCandidatesResponseModel> fetchCandidates({required int limit, required String examId}) async {
    return await remoteDataSource.fetchCandidates(limit: limit, examId: examId);
  }

  /// Upload candidate biometric
  @override
  Future<bool> uploadCandidateBiometric(CandidateModel candidate, String examID) async {
    return await remoteDataSource.uploadCandidateBiometric(candidate, examID);
  }
}
