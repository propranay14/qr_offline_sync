import 'package:flutter/material.dart';
import 'package:qr_offline_sync/core/service/permission_service.dart';

import '../../data/datasource/candidate_remote_datasource.dart';
import '../../data/local_db/local_db.dart';
import '../storage/session_manager.dart';

class SyncService {
  static Future<void> syncPendingBiometrics() async {
    final hasInternet = await PermissionService.hasInternet(null);

    if (!hasInternet) return;

    final localDb = LocalDb.instance;
    final repo = CandidateRemoteDatasource();

    final pending = await localDb.getPendingCandidates();
    final examID = await SessionManager.getExamId();

    for (final candidate in pending) {
      try {
        final uploaded = await repo.uploadCandidateBiometric(candidate, examID);

        if (uploaded) {
          await localDb.markCandidateSynced(candidate.id);
        }
      } catch (e, s) {
        debugPrint("Upload failed: $e");
        debugPrintStack(stackTrace: s);
      }
    }
  }
}
