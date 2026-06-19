import 'package:flutter/material.dart';
import 'package:qr_offline_sync/core/widgets/custom_cta_button.dart';
import 'package:qr_offline_sync/presentation/screens/qr_scanner_screen.dart';

import '../../data/service/permission_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true, automaticallyImplyLeading: false),
      body: Container(
        height: 100,
        margin: EdgeInsets.all(20),
        child: CustomCtaButton(
          onPressed: () async {
            final granted = await PermissionService.requestCamera(context);

            if (!granted) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen()));
          },
          text: "Scan QR",
        ),
      ),
    );
  }
}
