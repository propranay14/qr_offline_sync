import 'package:flutter/material.dart';
import 'package:qr_offline_sync/presentation/screens/sign_in_screen.dart';

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
    // listenForNetwork();
  }

  // Future<void> listenForNetwork() async {
  //   final hasInternet = await PermissionService.hasInternet(context);
  //
  //   if (!hasInternet) return;
  //   await SyncService.syncPending();
  // }

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
