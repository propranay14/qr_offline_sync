import 'package:dio/dio.dart';
import '../local_db/local_db.dart';

class SyncService {
  static Future<void> syncPending() async {
    final pending = await LocalDb.instance.getUnsynced();

    for (final item in pending) {
      try {
        await Dio().post(
          "YOUR_API_URL",
          data: item,
        );

        await LocalDb.instance.markSynced(item["id"]);
      } catch (_) {}
    }
  }
}