import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'core/service/background_sync_service.dart';
import 'splash_screen.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await BackgroundSyncService.sync();
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
