export 'report_exporter_stub.dart'
    if (dart.library.html) 'report_exporter_web.dart';

import '../models/audit_model.dart';

String generateHtmlReport(AuditResult result, RecommendationPlan plan) {
  final scoreColor = result.overallScore >= 75
      ? '#00D261'
      : (result.overallScore >= 50 ? '#FFB020' : '#FF4757');

  final scoreLabel = result.overallScore >= 75
      ? 'PASS'
      : (result.overallScore >= 50 ? 'WARNING' : 'FAIL');

  final nextBestAction = plan.recommendations.isEmpty
      ? 'All checked criteria passed. Keep this scan as the baseline for future accessibility checks.'
      : 'Start with ${plan.recommendations.first.issueTitle}: ${plan.recommendations.first.fix}';

  final recommendationsHtml = StringBuffer();
  for (final rec in plan.recommendations) {
    final severityColor = rec.severity == 'critical'
        ? '#FF4757'
        : (rec.severity == 'warning' ? '#FFB020' : '#00D261');

    final confidenceColor = rec.confidenceLevel == 'High confidence' ? '#00D261' : '#4F7DF7';
    final effortColor = '#FF8C42';

    recommendationsHtml.write('''
    <div class="card recommendation-card" style="border-left: 5px solid $severityColor;">
      <div class="card-header">
        <div class="priority-badge" style="background-color: ${severityColor}1f; color: $severityColor;">
          ${rec.priority}
        </div>
        <h3 class="issue-title">${rec.issueTitle}</h3>
        <span class="severity-badge" style="background-color: ${severityColor}1a; color: $severityColor;">
          ${rec.severity.toUpperCase()}
        </span>
      </div>

      <div class="chips-container">
        <div class="chip" style="background-color: ${severityColor}10; color: $severityColor;">
          <span class="chip-icon">⚡</span> ${rec.impactLevel}
        </div>
        <div class="chip" style="background-color: ${effortColor}10; color: $effortColor;">
          <span class="chip-icon">⚙️</span> ${rec.effortLevel}
        </div>
        <div class="chip" style="background-color: ${confidenceColor}10; color: $confidenceColor;">
          <span class="chip-icon">🛡️</span> ${rec.confidenceLevel}
        </div>
      </div>

      <div class="rec-sections">
        <div class="rec-section">
          <div class="section-title" style="color: #4F7DF7;"><span class="section-icon">ℹ️</span> Why it matters</div>
          <div class="section-body">${rec.explanation}</div>
        </div>
        <div class="rec-section">
          <div class="section-title" style="color: #00D261;"><span class="section-icon">🔧</span> Recommended fix <span class="cost-badge">${rec.costEffortTag}</span></div>
          <div class="section-body">${rec.fix}</div>
        </div>
        <div class="rec-section">
          <div class="section-title" style="color: #8B5CF6;"><span class="section-icon">📜</span> Standard reference</div>
          <div class="section-body">${rec.standard}</div>
        </div>
        <div class="rec-section">
          <div class="section-title" style="color: #FF8C42;"><span class="section-icon">✅</span> How to verify</div>
          <div class="section-body">${rec.verificationStep}</div>
        </div>
      </div>

      <div class="self-check-container">
        <span class="self-check-icon">🧠</span>
        <div class="self-check-text">${rec.selfCheck}</div>
      </div>
    </div>
    ''');
  }

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WheelScan AI Audit Report - ${result.spaceType}</title>
  <style>
    :root {
      --primary: #00D261;
      --bg: #F6F8FB;
      --card-bg: #FFFFFF;
      --text-main: #0F172A;
      --text-sub: #64748B;
      --border: #E2E8F0;
      --dark-surface: #1A1F2E;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bg);
      color: var(--text-main);
      line-height: 1.5;
      margin: 0;
      padding: 40px 20px;
    }

    .container {
      max-width: 800px;
      margin: 0 auto;
    }

    .header-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
      padding-bottom: 20px;
      border-bottom: 2px solid var(--border);
    }

    .brand-title {
      font-size: 24px;
      font-weight: 800;
      color: var(--primary);
      margin: 0;
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .brand-subtitle {
      font-size: 13px;
      color: var(--text-sub);
      margin: 5px 0 0 0;
      font-weight: 500;
    }

    .print-btn {
      background-color: var(--primary);
      color: white;
      border: none;
      padding: 10px 20px;
      border-radius: 10px;
      font-weight: 700;
      font-size: 13px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      box-shadow: 0 4px 12px rgba(0, 210, 97, 0.25);
      transition: all 0.2s ease;
    }

    .print-btn:hover {
      transform: translateY(-1px);
      box-shadow: 0 6px 16px rgba(0, 210, 97, 0.35);
    }

    .card {
      background: var(--card-bg);
      border-radius: 20px;
      box-shadow: 0 10px 25px rgba(15, 23, 42, 0.04), 0 2px 4px rgba(15, 23, 42, 0.02);
      padding: 24px;
      margin-bottom: 24px;
      border: 1px solid var(--border);
    }

    .hero-card {
      background: linear-gradient(135deg, #1A1F2E, #232A3B);
      color: white;
      border: none;
      display: flex;
      gap: 30px;
      align-items: center;
    }

    .score-circle {
      width: 110px;
      height: 110px;
      border-radius: 50%;
      border: 8px solid $scoreColor;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      flex-shrink: 0;
      box-shadow: 0 0 20px rgba(0, 0, 0, 0.2);
    }

    .score-value {
      font-size: 32px;
      font-weight: 900;
      color: white;
      line-height: 1;
    }

    .score-max {
      font-size: 11px;
      color: rgba(255, 255, 255, 0.5);
      margin-top: 2px;
      font-weight: 700;
    }

    .hero-info {
      flex-grow: 1;
    }

    .hero-info h2 {
      margin: 0 0 6px 0;
      font-size: 22px;
      font-weight: 800;
      letter-spacing: -0.3px;
    }

    .meta-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 10px;
      font-size: 13px;
      color: #94A3B8;
      margin-top: 15px;
    }

    .meta-item strong {
      color: white;
    }

    .next-action-card {
      background-color: rgba(0, 210, 97, 0.06);
      border: 1px solid rgba(0, 210, 97, 0.2);
      border-left: 4px solid var(--primary);
      padding: 16px;
      border-radius: 14px;
      margin-bottom: 24px;
    }

    .next-action-label {
      font-size: 11px;
      font-weight: 800;
      color: var(--primary);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 4px;
    }

    .next-action-text {
      font-size: 14px;
      font-weight: 500;
      color: var(--text-main);
    }

    .section-header {
      font-size: 18px;
      font-weight: 800;
      margin: 30px 0 15px 0;
      color: var(--text-main);
    }

    .recommendation-card {
      position: relative;
      transition: transform 0.2s ease;
    }

    .card-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 15px;
    }

    .priority-badge {
      width: 28px;
      height: 28px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 900;
      font-size: 13px;
    }

    .issue-title {
      font-size: 16px;
      font-weight: 700;
      margin: 0;
      flex-grow: 1;
    }

    .severity-badge {
      font-size: 9px;
      font-weight: 800;
      letter-spacing: 0.7px;
      padding: 4px 8px;
      border-radius: 6px;
    }

    .chips-container {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 16px;
    }

    .chip {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      font-size: 11px;
      font-weight: 700;
      padding: 5px 10px;
      border-radius: 8px;
      border: 1px solid rgba(0, 0, 0, 0.03);
    }

    .rec-sections {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .rec-section {
      background-color: var(--bg);
      border-radius: 12px;
      padding: 12px 16px;
    }

    .section-title {
      font-size: 11px;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.3px;
      margin-bottom: 4px;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .cost-badge {
      font-size: 9px;
      background-color: var(--primary);
      color: white;
      padding: 1px 5px;
      border-radius: 4px;
      font-weight: 900;
      margin-left: 8px;
      text-transform: none;
      letter-spacing: 0;
    }

    .section-body {
      font-size: 13.5px;
      color: var(--text-main);
      font-weight: 500;
    }

    .self-check-container {
      margin-top: 15px;
      padding-top: 12px;
      border-top: 1px solid var(--border);
      display: flex;
      gap: 8px;
      align-items: flex-start;
    }

    .self-check-icon {
      font-size: 14px;
      margin-top: 1px;
    }

    .self-check-text {
      font-size: 11px;
      color: var(--text-sub);
      font-style: italic;
    }

    .self-review-banner {
      background-color: #f1f5f9;
      border: 1px solid var(--border);
      padding: 14px;
      border-radius: 14px;
      display: flex;
      gap: 10px;
      margin-top: 30px;
      align-items: center;
    }

    .self-review-text {
      font-size: 12px;
      color: var(--text-sub);
      font-weight: 500;
    }

    @media print {
      body {
        background-color: white;
        padding: 0;
      }
      .print-btn {
        display: none;
      }
      .card {
        box-shadow: none;
        page-break-inside: avoid;
      }
      .hero-card {
        background: #1A1F2E !important;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header-bar">
      <div>
        <h1 class="brand-title">🟢 WheelScan</h1>
        <p class="brand-subtitle">AI-Assisted Physical Accessibility Audit Report</p>
      </div>
      <button class="print-btn" onclick="window.print()">
        <span>🖨️</span> Save as PDF / Print
      </button>
    </div>

    <!-- Hero Card -->
    <div class="card hero-card">
      <div class="score-circle">
        <span class="score-value">${result.overallScore}</span>
        <span class="score-max">/ 100</span>
      </div>
      <div class="hero-info">
        <h2>${result.spaceType} Audit Result</h2>
        <div style="font-size: 14px; font-weight: 700; color: #00D261; text-transform: uppercase; letter-spacing: 0.5px;">
          Overall Status: $scoreLabel
        </div>
        <div class="meta-grid">
          <div class="meta-item">Location: <strong>${result.locationName}</strong></div>
          <div class="meta-item">Date: <strong>${result.timestamp.toString().substring(0, 16)}</strong></div>
        </div>
      </div>
    </div>

    <!-- Next Action -->
    <div class="next-action-card">
      <div class="next-action-label">Next Best Action</div>
      <div class="next-action-text">$nextBestAction</div>
    </div>

    <h2 class="section-header">Prioritized AI Action Plan</h2>

    <!-- Recommendations -->
    ${recommendationsHtml.toString()}

    <!-- Agent Self-Review Summary -->
    <div class="self-review-banner">
      <span style="font-size: 18px;">🛡️</span>
      <div class="self-review-text">${plan.selfReviewSummary}</div>
    </div>
  </div>
</body>
</html>
  ''';
}
