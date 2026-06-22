import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> _showNoInternetDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("No Internet"),
          content: const Text("Internet connection is required to continue."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        );
      },
    );
  }

  static Future<bool> hasInternet(BuildContext? context) async {
    final result = await Connectivity().checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      if (context != null) await _showNoInternetDialog(context);
      return false;
    }

    return true;
  }

  static Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    return _handleStatus(context, status, "Camera");
  }

  static Future<bool> requestBluetooth(BuildContext context) async {
    final status = await Permission.bluetoothConnect.request();
    return _handleStatus(context, status, "Bluetooth");
  }

  static Future<bool> requestStorage(BuildContext context) async {
    final status = await Permission.storage.request();
    return _handleStatus(context, status, "Storage");
  }

  static Future<bool> _handleStatus(BuildContext context, PermissionStatus status, String permissionName) async {
    if (status.isGranted) {
      return true;
    }

    await _showPermissionDialog(context, permissionName);

    return false;
  }

  static Future<void> _showPermissionDialog(BuildContext context, String permissionName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Permission Required"),
          content: Text("$permissionName permission is required to continue. Please enable it from settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }
}
