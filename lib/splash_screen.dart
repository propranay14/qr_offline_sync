import 'package:flutter/material.dart';
import 'package:qr_offline_sync/presentation/screens/home_screen.dart';
import 'package:qr_offline_sync/presentation/screens/sign_in_screen.dart';

import 'core/storage/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await SessionManager.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF023020),
      body: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100),
        child: Image.asset("assets/icon/app_icon.png"),
      )),
    );
  }
}
