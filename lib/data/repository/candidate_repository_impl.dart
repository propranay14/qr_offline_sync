import 'package:qr_offline_sync/data/datasource/auth_remote_datasource.dart';

import '../../domain/repository/candidate_repository.dart';
import '../model/candidate_sync_response_model.dart';

class CandidateRepositoryImpl implements CandidateRepository {
  final AuthRemoteDataSource remoteDataSource;

  CandidateRepositoryImpl(this.remoteDataSource);

  @override
  Future<CandidateSyncResponseModel> syncCandidates({required int lastCandidateId, required int limit}) async {
    return await remoteDataSource.syncCandidates(lastCandidateId: lastCandidateId, limit: limit);
  }
}
