import 'package:qr_offline_sync/data/datasource/candidate_remote_datasource.dart';

import '../../domain/repository/candidate_repository.dart';
import '../local_db/local_db.dart';
import '../model/candidate_sync_response_model.dart';

class CandidateRepositoryImpl implements CandidateRepository {
  final CandidateRemoteDatasource remoteDataSource;
  final LocalDb localDb;

  CandidateRepositoryImpl(this.remoteDataSource, this.localDb);

  @override
  Future<CandidateSyncResponseModel> syncCandidates({required int lastCandidateId, required int limit}) async {
    return await remoteDataSource.syncCandidates(lastCandidateId: lastCandidateId, limit: limit);
  }

  @override
  Future<void> syncAllCandidates({required int lastCandidateId}) async {
    int currentLastId = lastCandidateId;
    bool hasMore = true;

    while (hasMore) {
      final response = await syncCandidates(lastCandidateId: currentLastId, limit: 50);

      for (final candidate in response.data) {
        await localDb.insertCandidate(candidate);
      }

      hasMore = response.hasMore;
      currentLastId = response.nextCandidateId;
    }
  }
}
