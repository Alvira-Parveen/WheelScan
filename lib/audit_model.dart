class AuditResult {
  final String spaceType;      // "Ramp", "Doorway", "Elevator", "Parking", "Staircase"
  final int overallScore;       // 0–100
  final List<AuditIssue> issues;
  final String imagePath;
  final DateTime timestamp;
  final String locationName;

  AuditResult({
    required this.spaceType,
    required this.overallScore,
    required this.issues,
    required this.imagePath,
    required this.timestamp,
    required this.locationName,
  });
}

class AuditIssue {
  final String title;
  final String description;
  final String severity;       // "good", "warning", "critical"
  final String recommendation;

  AuditIssue({
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendation,
  });
}