import 'package:flutter/material.dart';

class ProgressLoaderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final int progress;

  const ProgressLoaderScreen({super.key, required this.title, required this.subtitle, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                Text(subtitle, textAlign: TextAlign.center),

                const SizedBox(height: 40),

                SizedBox(
                  height: 90,
                  width: 90,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(value: progress / 100, strokeWidth: 8),

                      Center(
                        child: Text("$progress%", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                LinearProgressIndicator(value: progress / 100, minHeight: 10, borderRadius: BorderRadius.circular(8)),

                const SizedBox(height: 20),

                const Text("Please don't close the application.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
