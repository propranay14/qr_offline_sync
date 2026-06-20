class CandidateSyncRequestModel {
  final int lastCandidateId;
  final int limit;

  CandidateSyncRequestModel({
    required this.lastCandidateId,
    required this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      "last_candidate_id": lastCandidateId,
      "limit": limit,
    };
  }
}