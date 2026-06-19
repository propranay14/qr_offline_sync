import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:qr_offline_sync/presentation/screens/home_screen.dart';
import 'package:qr_offline_sync/presentation/screens/sign_in_screen.dart';

import 'data/service/sync_service.dart';

void main() {
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
    listenForNetwork();
  }

  void listenForNetwork() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result.isNotEmpty) {
        await SyncService.syncPending();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Verification',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInScreen(),
    );
  }
}
