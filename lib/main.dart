import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'core/service/sync_service.dart';
import 'splash_screen.dart';

/// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      await SyncService.syncPendingBiometrics();

      return Future.value(true);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return Future.value(false);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Firebase init
  await Firebase.initializeApp();

  /// Crashlytics for Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  /// Crashlytics for native/platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  /// Initialize Workmanager
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  /// Sync immediately when app starts
  await SyncService.syncPendingBiometrics();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    registerBackgroundSync();
  }

  Future<void> registerBackgroundSync() async {
    await Workmanager().registerPeriodicTask("candidate_sync_task", "candidate_sync_task", frequency: const Duration(minutes: 15));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
