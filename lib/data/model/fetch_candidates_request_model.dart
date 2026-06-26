class FetchCandidatesRequestModel {
  final int lastCandidateId;
  final int limit;

  FetchCandidatesRequestModel({
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