import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/service/permission_service.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/custom_cta_button.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/model/operator_info_request_model.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/usecase/auth_usecase.dart';
import 'home_screen.dart';

class LivePhotoScreen extends StatefulWidget {
  const LivePhotoScreen({super.key});

  @override
  State<LivePhotoScreen> createState() => _LivePhotoScreenState();
}

class _LivePhotoScreenState extends State<LivePhotoScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final Geocoding _geocoding = Geocoding();

  XFile? _capturedPhoto;
  Position? _currentLocation;

  bool _cameraReady = false;
  bool _capturing = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  /// Requests permissions, initializes camera, fetches current location and starts the clock shown on the screen.
  Future<void> _initialize() async {
    await PermissionService.requestCamera(context);
    await PermissionService.requestLocation(context);

    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(frontCamera, ResolutionPreset.high, enableAudio: false);

    await _cameraController!.initialize();

    try {
      _currentLocation = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    } catch (_) {}

    if (!mounted) return;

    setState(() => _cameraReady = true);
  }

  /// Captures photo from the front camera.
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _capturing) {
      return;
    }

    setState(() => _capturing = true);

    try {
      _capturedPhoto = await _cameraController!.takePicture();

      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() => _capturing = false);
      }
    }
  }

  /// Converts latitude & longitude into a readable address.
  Future<String> _getAddress() async {
    if (_currentLocation == null) return "";

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);

      if (placemarks.isEmpty) return "";

      final place = placemarks.first;

      return [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e != null && e.trim().isNotEmpty).join(", ");
    } catch (_) {
      return "";
    }
  }

  /// Updates operator information and navigates to Home.
  Future<void> _continue() async {
    if (_capturedPhoto == null || _currentLocation == null) return;

    setState(() => _uploading = true);

    try {
      final session = await SessionManager.getLoginSession();
      if (session == null) return;

      final request = OperatorInfoRequestModel(
        examId: session.examInfo?.examId ?? "No exam allocated",
        operatorId: session.userInfo.username,
        geo: "${_currentLocation!.latitude},${_currentLocation!.longitude}",
        address: await _getAddress(),
        photoPath: _capturedPhoto?.path ?? "",
      );

      final authUseCase = AuthUseCase(AuthRepositoryImpl(AuthRemoteDataSource()));

      final success = await authUseCase.updateOperatorInfo(request);

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to upload operator information")));
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Operator Verification", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: !_cameraReady
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _capturedPhoto == null
                                ? CameraPreview(_cameraController!)
                                : Image.file(File(_capturedPhoto!.path), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      if (_capturedPhoto == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 20, bottom: 24),
                          child: CustomCtaButton(text: _capturing ? "Capturing..." : "Capture Photo", onPressed: _capturing ? null : _capturePhoto),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 20, bottom: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => setState(() => _capturedPhoto = null),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Retake"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomCtaButton(text: "Continue", onPressed: _continue),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          _uploading ? Center(child: const CircularProgressIndicator()) : const SizedBox(),
        ],
      ),
    );
  }
}
