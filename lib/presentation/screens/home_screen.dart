import 'package:flutter/material.dart';
import 'package:qr_offline_sync/core/widgets/custom_cta_button.dart';
import 'package:qr_offline_sync/data/model/candidate_sync_response_model.dart';
import 'package:qr_offline_sync/presentation/screens/candidate_details_screen.dart';
import 'package:qr_offline_sync/presentation/screens/qr_scanner_screen.dart';
import 'package:qr_offline_sync/presentation/screens/sign_in_screen.dart';

import '../../core/service/permission_service.dart';
import '../../core/storage/session_manager.dart';
import '../../data/datasource/candidate_remote_datasource.dart';
import '../../data/local_db/local_db.dart';
import '../../data/repository/candidate_repository_impl.dart';
import '../../domain/usecase/candidates_sync_usecase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CandidateModel> candidates = [];
  final TextEditingController searchController = TextEditingController();

  Future<void> searchCandidate() async {
    final result = await LocalDb.instance.searchCandidate(searchController.text);

    setState(() {
      candidates = result;
    });
  }

  Future<void> scanQr() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => QRScannerScreen()));
  }

  Future<void> syncCandidates() async {
    final hasInternet = await PermissionService.hasInternet(context);
    if (!hasInternet) return;

    /// LOCAL LAST ID
    int localLastCandidateId = await LocalDb.instance.getLastCandidateId();

    debugPrint("Local Last Candidate ID: $localLastCandidateId");

    /// SYNC
    final syncUseCase = CandidatesSyncUseCase(CandidateRepositoryImpl(CandidateRemoteDatasource(), LocalDb.instance));

    bool hasMore = true;
    int nextCandidateId = localLastCandidateId;

    while (hasMore) {
      final syncResponse = await syncUseCase.call(lastCandidateId: nextCandidateId, limit: 50);

      if (syncResponse.success && syncResponse.data.isNotEmpty) {
        await LocalDb.instance.insertCandidates(syncResponse.data);

        debugPrint("Saved ${syncResponse.data.length} candidates");
      }

      nextCandidateId = syncResponse.nextCandidateId;
      hasMore = syncResponse.hasMore;

      debugPrint("Next Candidate ID: $nextCandidateId | Has More: $hasMore");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(onPressed: syncCandidates, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () => showLogoutDialog(context), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Enter Application ID",
                suffixIcon: IconButton(onPressed: searchCandidate, icon: const Icon(Icons.search)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text("Or")),
            const SizedBox(height: 20),
            CustomCtaButton(onPressed: scanQr, text: "Scan QR"),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final candidate = candidates[index];

                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CandidateDetailsScreen(candidate: candidate)));
                      },
                      title: Text(candidate.candidateName),
                      subtitle: Text(candidate.applicationId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?\nAll locally synced candidate data will be removed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await LocalDb.instance.clearCandidates();
                await SessionManager.logout();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => SignInScreen()), (route) => false);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
