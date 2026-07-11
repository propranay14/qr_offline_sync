import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:qr_offline_sync/presentation/screens/home_screen.dart';

import '../../core/service/permission_service.dart';
import '../../core/widgets/custom_cta_button.dart';

class LivePhotoScreen extends StatefulWidget {
  const LivePhotoScreen({super.key});

  @override
  State<LivePhotoScreen> createState() => _LivePhotoScreenState();
}

class _LivePhotoScreenState extends State<LivePhotoScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;

  bool isCameraReady = false;
  bool isCapturing = false;

  XFile? capturedPhoto;

  Position? currentLocation;

  DateTime currentTime = DateTime.now();

  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    initialize();
  }

  Future<void> initialize() async {
    await PermissionService.requestCamera(context);
    await PermissionService.requestLocation(context);

    await initializeCamera();
    await fetchLocation();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(frontCamera, ResolutionPreset.high, enableAudio: false);

    await _cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      isCameraReady = true;
    });
  }

  Future<void> fetchLocation() async {
    try {
      currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> capturePhoto() async {
    if (_cameraController == null) return;

    if (!_cameraController!.value.isInitialized) return;

    setState(() {
      isCapturing = true;
    });

    try {
      capturedPhoto = await _cameraController!.takePicture();

      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() {
          isCapturing = false;
        });
      }
    }
  }

  void retakePhoto() {
    setState(() {
      capturedPhoto = null;
    });
  }

  void continueNext() {
    if (capturedPhoto == null || currentLocation == null) return;

    print(
      "photo: ${capturedPhoto!.path}, latitude: ${currentLocation!.latitude},longitude: ${currentLocation!.longitude},capture_time: ${currentTime.toIso8601String()}",
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  void dispose() {
    timer?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    _cameraController?.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera();
    }
  }

  String get formattedDate => DateFormat("dd MMM yyyy").format(currentTime);

  String get formattedTime => DateFormat("hh:mm:ss a").format(currentTime);

  String get formattedLocation {
    if (currentLocation == null) {
      return "Fetching location...";
    }

    return "${currentLocation!.latitude.toStringAsFixed(6)}, "
        "${currentLocation!.longitude.toStringAsFixed(6)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Operator Verification", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: isCameraReady
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 10),
                                Expanded(child: Text(formattedDate, style: const TextStyle(fontSize: 15))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(width: 10),
                                Expanded(child: Text(formattedTime, style: const TextStyle(fontSize: 15))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(width: 10),
                                Expanded(child: Text(formattedLocation, style: const TextStyle(fontSize: 15))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: capturedPhoto == null ? CameraPreview(_cameraController!) : Image.file(File(capturedPhoto!.path), fit: BoxFit.cover),
                      ),
                    ),

                    const SizedBox(height: 25),

                    if (capturedPhoto == null)
                      CustomCtaButton(
                        onPressed: isCapturing
                            ? null
                            : () async {
                                await capturePhoto();
                              },
                        text: isCapturing ? "Capturing..." : "Capture Photo",
                      ),

                    if (capturedPhoto != null)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: retakePhoto,
                              icon: const Icon(Icons.refresh),
                              label: const Text("Retake"),
                              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: CustomCtaButton(onPressed: continueNext, text: "Continue"),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
