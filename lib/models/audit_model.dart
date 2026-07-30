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

class RecommendationPlan {
  final String spaceType;
  final List<AccessibilityRecommendation> recommendations;
  final String selfReviewSummary;

  const RecommendationPlan({
    required this.spaceType,
    required this.recommendations,
    required this.selfReviewSummary,
  });

  bool get hasRecommendations => recommendations.isNotEmpty;
}

class AccessibilityRecommendation {
  final int priority;
  final String issueTitle;
  final String severity;
  final String impactLevel;
  final String effortLevel;
  final String explanation;
  final String fix;
  final String standard;
  final String verificationStep;
  final String selfCheck;
  final String confidenceLevel;
  final String costEffortTag;

  const AccessibilityRecommendation({
    required this.priority,
    required this.issueTitle,
    required this.severity,
    required this.impactLevel,
    required this.effortLevel,
    required this.explanation,
    required this.fix,
    required this.standard,
    required this.verificationStep,
    required this.selfCheck,
    required this.confidenceLevel,
    required this.costEffortTag,
  });
}

