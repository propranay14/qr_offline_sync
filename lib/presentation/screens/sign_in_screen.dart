import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_offline_sync/domain/usecase/validation_form.dart';
import 'package:qr_offline_sync/presentation/screens/home_screen.dart';
import 'package:qr_offline_sync/presentation/screens/live_photo_screen.dart';

import '../../core/service/permission_service.dart';
import '../../core/storage/session_manager.dart';
import '../../core/widgets/custom_cta_button.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/datasource/candidate_remote_datasource.dart';
import '../../data/local_db/local_db.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../data/repository/candidate_repository_impl.dart';
import '../../domain/usecase/candidates_usecase.dart';
import '../../domain/usecase/auth_usecase.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    final hasInternet = await PermissionService.hasInternet(context);
    if (!hasInternet) return;

    setState(() {
      isLoading = true;
    });

    try {
      /// LOGIN
      final loginUseCase = AuthUseCase(AuthRepositoryImpl(AuthRemoteDataSource()));

      /// API Call
      final loginResponse = await loginUseCase.call(username: usernameController.text.trim(), password: passwordController.text.trim());

      /// API Response
      if (!loginResponse.success) {
        Fluttertoast.showToast(msg: "Invalid credentials");
        return;
      }

      /// Sync Candidates from server
      await fetchCandidates(loginResponse.fetchLimit, loginResponse.examInfo?.examId ?? '');

      /// Save Session for Operator
      await SessionManager.saveLoginSession(loginResponse);

      if (!mounted) return;
      Fluttertoast.showToast(msg: "Login successful");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => (loginResponse.examInfo == null) ? LivePhotoScreen() : HomeScreen()));
    } catch (e, stackTrace) {
      debugPrint("Login Error: $e");
      debugPrint("StackTrace: $stackTrace");

      String errorMessage = "Something went wrong";

      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = e.response?.data["message"] ?? "Invalid username or password";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = "No internet connection";
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = "Connection timeout";
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = "Server timeout";
        } else {
          errorMessage = e.response?.data["message"] ?? "Server error";
        }
      }

      Fluttertoast.showToast(msg: errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchCandidates(int limit, String examId) async {
    try {
      final hasInternet = await PermissionService.hasInternet(context);
      if (!hasInternet) return;

      /// SYNC
      final fetchUseCase = CandidatesUseCase(CandidateRepositoryImpl(CandidateRemoteDatasource(), LocalDb.instance));

      bool hasMore = true;

      while (hasMore) {
        try {
          final syncResponse = await fetchUseCase.call(limit: limit, examId: examId);

          if (syncResponse.success && syncResponse.data.isNotEmpty) {
            await LocalDb.instance.insertCandidates(syncResponse.data);

            debugPrint("Saved ${syncResponse.data.length} candidates");
          }

          hasMore = syncResponse.hasMore;

          debugPrint("Has More: $hasMore");
        } catch (e, stackTrace) {
          debugPrint("Sync Loop Error: $e");
          debugPrintStack(stackTrace: stackTrace);

          rethrow;
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Fetch Candidates Error: $e");
      debugPrint("Exam ID: $examId | Limit: $limit");
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Title
                Text("Operator Login", style: TextStyle(fontSize: 32, color: colorScheme.primary)),
                const SizedBox(height: 32),

                /// Username
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    counterText: '',
                  ),
                  maxLength: 32,
                  style: TextStyle(color: colorScheme.onSurface),
                  validator: (value) => SignInValidator.validateUsername(value ?? '')?.errorMessage,
                ),
                const SizedBox(height: 20),

                /// Password
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    counterText: '',
                  ),
                  maxLength: 16,
                  style: TextStyle(color: colorScheme.onSurface),
                  obscureText: obscurePassword,
                  validator: (value) => SignInValidator.validatePassword(value ?? '')?.errorMessage,
                ),
                const SizedBox(height: 20),

                isLoading ? const CircularProgressIndicator() : CustomCtaButton(text: "Sign In", onPressed: signIn),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
