import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_offline_sync/presentation/screens/candidate_details_screen.dart';
import 'package:qr_offline_sync/presentation/screens/qr_scanner_screen.dart';
import 'package:qr_offline_sync/presentation/screens/sign_in_screen.dart';

import '../../core/storage/session_manager.dart';
import '../../data/datasource/candidate_remote_datasource.dart';
import '../../data/local_db/local_db.dart';
import '../../data/model/fetch_candidates_response_model.dart';
import '../../data/repository/candidate_repository_impl.dart';
import '../../domain/usecase/candidates_usecase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CandidateModel> candidates = [];
  final TextEditingController searchController = TextEditingController();

  String operatorName = "";
  String username = "";
  String role = "";
  String mobile = "";
  String email = "";

  String? examId = "";
  String? examDate = "";
  String? examStartTime = "";
  String? examEndTime = "";
  String? examRemarks = "";
  String? examStatus = "";

  @override
  void initState() {
    super.initState();
    loadOperator();
  }

  Future<void> loadOperator() async {
    final session = await SessionManager.getLoginSession();

    if (session == null) return;

    final user = session.userInfo;
    final exam = session.examInfo;

    operatorName = "${user.firstName} ${user.middleName ?? ""} ${user.lastName}".trim();

    username = user.username;
    role = user.roleName;
    mobile = user.contactMobile;
    email = user.contactEmail;

    examId = exam?.examId;
    examDate = exam?.examDate;
    examStartTime = exam?.examStartTime;
    examEndTime = exam?.examEndTime;
    examRemarks = exam?.remarks ?? "";
    examStatus = exam?.status;

    setState(() {});
  }

  Future<void> searchCandidate() async {
    final query = searchController.text.trim();

    final result = await LocalDb.instance.searchCandidate(query);

    setState(() {
      candidates = result;
    });
  }

  Future<void> scanQr() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen()));
  }

  Widget infoTile(IconData icon, String? value) {
    if (value == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: CircleAvatar(radius: 32, child: Icon(Icons.person, size: 34))),

                    const SizedBox(height: 12),

                    Text(
                      operatorName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text("@$username", style: const TextStyle(color: Colors.white70, fontSize: 13)),

                    const Divider(color: Colors.white54),

                    infoTile(Icons.badge, role),
                    infoTile(Icons.phone, mobile),
                    infoTile(Icons.email, email),

                    (examId == null)
                        ? SizedBox()
                        : Column(
                            children: [
                              const SizedBox(height: 8),
                              const Text(
                                "Exam Details",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),

                              const SizedBox(height: 6),

                              infoTile(Icons.confirmation_number, examId),
                              infoTile(Icons.calendar_today, examDate),
                              infoTile(Icons.access_time, "$examStartTime - $examEndTime"),
                              infoTile(Icons.info_outline, examStatus),
                            ],
                          ),
                  ],
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

                  final hasPending = await LocalDb.instance.getPendingCandidates();

                  if (hasPending.isNotEmpty) {
                    await showPendingSyncDialog(context);
                  } else {
                    await showLogoutDialog(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Verification", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final fetchUseCase = CandidatesUseCase(CandidateRepositoryImpl(CandidateRemoteDatasource(), LocalDb.instance));
              final localDb = LocalDb.instance;
              final pending = await localDb.getPendingCandidates();
              if (pending.isEmpty) {
                Fluttertoast.showToast(msg: "No pending candidates to sync");
                return;
              }
              for (final candidate in pending) {
                try {
                  final uploaded = await fetchUseCase.uploadCandidateBiometric(candidate, examId ?? "");

                  if (uploaded) {
                    Fluttertoast.showToast(msg: "Candidates synced successfully");
                    await localDb.markCandidateSynced(candidate.id);
                  }
                } catch (e, stacktrace) {
                  debugPrintStack(stackTrace: stacktrace);
                }
              }
            },
            icon: Icon(Icons.cloud_upload_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Exam ID: $examId", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        hintText: "Application Number",
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) async {
                        await searchCandidate();
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  height: 55,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFA5D6A7), Color(0xFF4FC3A1)],
                    ),
                  ),
                  child: IconButton(
                    onPressed: scanQr,
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.black, size: 28),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  height: 55,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFA5D6A7), Color(0xFF4FC3A1)],
                    ),
                  ),
                  child: IconButton(
                    onPressed: searchCandidate,
                    icon: const Icon(Icons.search, color: Colors.black),
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
                            subtitle: Text(candidate.applicationNumber),
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
