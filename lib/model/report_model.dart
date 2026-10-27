class ReportModel {
  final String productId;
  final String reporterUid;
  final String reason;
  final DateTime createdAt;
  ReportModel({required this.productId, required this.reporterUid,
    required this.reason, required this.createdAt});
  Map<String, dynamic> toMap() => {
    'productId': productId,
    'reporterUid': reporterUid,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };
}
