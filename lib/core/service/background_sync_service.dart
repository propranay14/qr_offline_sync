import 'package:qr_offline_sync/core/service/permission_service.dart';
import 'package:qr_offline_sync/data/datasource/candidate_remote_datasource.dart';

import '../../data/local_db/local_db.dart';
import '../../data/repository/candidate_repository_impl.dart';

class BackgroundSyncService {
  static Future<void> sync() async {
    final hasInternet = await PermissionService.hasInternet(null);

    if (!hasInternet) return;

    final localDb = LocalDb.instance;

    final lastId = await localDb.getLastCandidateId();

    final repo = CandidateRepositoryImpl(CandidateRemoteDatasource(), localDb);

    await repo.syncAllCandidates(lastCandidateId: lastId);
  }
}
