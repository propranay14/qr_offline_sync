import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_service.dart';

class ConnectivitySyncService {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void startListening() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) async {
      final hasInternet = results.any(
            (result) => result != ConnectivityResult.none,
      );

      if (hasInternet) {
        await SyncService.syncPendingBiometrics();
      }
    });
  }

  static void dispose() {
    _subscription?.cancel();
  }
}