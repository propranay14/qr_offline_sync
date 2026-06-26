import 'package:flutter/material.dart';
import 'package:qr_offline_sync/core/service/permission_service.dart';
import 'package:qr_offline_sync/presentation/screens/candidate_details_screen.dart';
import 'package:qr_offline_sync/presentation/screens/qr_scanner_screen.dart';
import 'package:qr_offline_sync/presentation/screens/sign_in_screen.dart';

import '../../core/storage/session_manager.dart';
import '../../data/local_db/local_db.dart';
import '../../data/model/fetch_candidates_response_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CandidateModel> candidates = [];
  final TextEditingController searchController = TextEditingController();

  String operatorName = "";
  String role = "";
  String mobile = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadOperator();
  }

  Future<void> loadOperator() async {
    operatorName = await SessionManager.getFullName();
    role = await SessionManager.getRoleName();
    mobile = await SessionManager.getMobile();
    email = await SessionManager.getEmail();

    setState(() {});
  }

  Future<void> searchCandidate() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        candidates = [];
      });
      return;
    }

    final result = await LocalDb.instance.searchCandidate(query);

    setState(() {
      candidates = result;
    });
  }

  Future<void> scanQr() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 30))),
                    const SizedBox(height: 10),
                    Text(
                      operatorName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(role, style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(mobile, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search Candidate"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                Navigator.pop(context);

                final hasPending = await PermissionService.hasInternet(null);/*await LocalDb.instance.hasPendingSync()*/;

                if (!hasPending) {
                  await showPendingSyncDialog(context);
                } else {
                  await showLogoutDialog(context);
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Exam 1", style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Candidate ID",
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                InkWell(
                  onTap: scanQr,
                  child: Container(
                    height: 55,
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.qr_code_scanner, size: 28),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  height: 55,
                  width: 60,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(6)),
                  child: IconButton(
                    onPressed: searchCandidate,
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: searchController.text.trim().isEmpty
                  ? const Center(child: Text("Search candidate by ID or scan QR", style: TextStyle(fontSize: 16)))
                  : candidates.isEmpty
                  ? const Center(
                      child: Text("No candidate found", style: TextStyle(fontSize: 16, color: Colors.red)),
                    )
                  : ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];

                        return Card(
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => CandidateDetailsScreen(candidate: candidate)));

                              await searchCandidate();
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

  Future<void> showPendingSyncDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Sync Pending"),
          content: const Text("Some candidate data is not yet synced to the server.\nPlease connect to internet and complete sync before logout."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
