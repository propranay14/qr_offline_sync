class FetchCandidatesRequestModel {
  final int lastCandidateId;
  final int limit;
  final String examId;

  FetchCandidatesRequestModel({required this.lastCandidateId, required this.limit, required this.examId});

  Map<String, dynamic> toJson() {
    return {"last_candidate_id": lastCandidateId, "limit": limit, "exam_id": examId};
  }
}
