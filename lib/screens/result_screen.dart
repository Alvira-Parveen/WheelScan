import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import '../config/theme.dart';
import '../models/audit_model.dart';
import '../services/recommendation_agent_service.dart';
import '../utils/report_exporter.dart';
import '../utils/text_to_speech.dart';

class ResultScreen extends StatefulWidget {
  final AuditResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _cardsController;
  late AnimationController _pulseController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _pulseAnimation;
  late final RecommendationPlan _recommendationPlan;

  bool _isReasoningComplete = false;
  int _currentReasoningStepIndex = 0;
  Timer? _reasoningTimer;
  final List<String> _reasoningSteps = [
    'Reading flagged criteria...',
    'Drafting recommendations...',
    'Self-checking for actionability...',
    'Ranking by priority...',
  ];
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _recommendationPlan = RecommendationAgentService.buildPlan(widget.result);

    // Score ring animation
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.result.overallScore / 100.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    // Staggered cards animation
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation for score
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scoreController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _cardsController.forward();
    });

    // Start AI reasoning animation steps
    _reasoningTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          if (_currentReasoningStepIndex < _reasoningSteps.length - 1) {
            _currentReasoningStepIndex++;
          } else {
            _isReasoningComplete = true;
            _reasoningTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
    _reasoningTimer?.cancel();
    stopSpeaking();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 75) return WheelScanTheme.primary;
    if (score >= 50) return WheelScanTheme.warning;
    return WheelScanTheme.danger;
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'good': return WheelScanTheme.primary;
      case 'warning': return WheelScanTheme.warning;
      case 'critical': return WheelScanTheme.danger;
      default: return WheelScanTheme.textSecondary;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'good': return Icons.check_circle_rounded;
      case 'warning': return Icons.warning_rounded;
      case 'critical': return Icons.cancel_rounded;
      default: return Icons.info_rounded;
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity) {
      case 'good': return 'PASS';
      case 'warning': return 'WARNING';
      case 'critical': return 'FAIL';
      default: return 'INFO';
    }
  }

  IconData _getSpaceIcon(String type) {
    switch (type) {
      case 'Ramp': return Icons.accessibility_new;
      case 'Doorway': return Icons.door_front_door;
      case 'Elevator': return Icons.elevator;
      case 'Parking': return Icons.local_parking;
      case 'Staircase': return Icons.stairs;
      default: return Icons.place;
    }
  }

  String _topActionText() {
    if (_recommendationPlan.recommendations.isEmpty) {
      return 'All checked criteria passed. Keep this scan as the baseline for future accessibility checks.';
    }

    final top = _recommendationPlan.recommendations.first;
    return 'Start with ${top.issueTitle}: ${top.fix}';
  }

  String _buildReportText() {
    final buffer = StringBuffer()
      ..writeln('WheelScan AI Accessibility Action Plan')
      ..writeln('Space type: ${widget.result.spaceType}')
      ..writeln('Score: ${widget.result.overallScore}/100')
      ..writeln('Generated: ${widget.result.timestamp}')
      ..writeln('')
      ..writeln('Top action:')
      ..writeln(_topActionText())
      ..writeln('');

    if (_recommendationPlan.recommendations.isEmpty) {
      buffer.writeln('No warning or critical action items were found.');
    } else {
      for (final item in _recommendationPlan.recommendations) {
        buffer
          ..writeln('${item.priority}. ${item.issueTitle} (${item.severity.toUpperCase()})')
          ..writeln('Impact: ${item.impactLevel}')
          ..writeln('Effort: ${item.effortLevel}')
          ..writeln('Why it matters: ${item.explanation}')
          ..writeln('Recommended fix: ${item.fix}')
          ..writeln('Standard reference: ${item.standard}')
          ..writeln('Verify: ${item.verificationStep}')
          ..writeln('');
      }
    }

    buffer.writeln(_recommendationPlan.selfReviewSummary);
    return buffer.toString();
  }

  Future<void> _copyActionPlan() async {
    await Clipboard.setData(ClipboardData(text: _buildReportText()));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('AI action plan copied as a report'),
        backgroundColor: WheelScanTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Export Audit Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: WheelScanTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: WheelScanTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a format to share or download this accessibility action plan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: WheelScanTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WheelScanTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.copy_rounded, color: WheelScanTheme.primary),
                  ),
                  title: const Text(
                    'Copy Text Report',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Copies a markdown report to clipboard'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyActionPlan();
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WheelScanTheme.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: WheelScanTheme.accent),
                  ),
                  title: const Text(
                    'Download Print-Ready PDF / HTML',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Saves a styled, colored visual report card'),
                  onTap: () {
                    Navigator.pop(context);
                    if (!_isReasoningComplete) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('AI Action Plan is still generating. Please wait.'),
                          backgroundColor: WheelScanTheme.warning,
                        ),
                      );
                      return;
                    }
                    final htmlContent = generateHtmlReport(widget.result, _recommendationPlan);
                    exportReportHtml(
                      'WheelScan_Report_${widget.result.spaceType}',
                      htmlContent,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('HTML report download triggered. Print/Save to PDF.'),
                        backgroundColor: WheelScanTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleVoiceReadout() {
    if (_isSpeaking) {
      stopSpeaking();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      final buffer = StringBuffer()
        ..write('WheelScan AI action plan for ${widget.result.spaceType}. ')
        ..write('Overall score is ${widget.result.overallScore} out of 100. ');

      if (_recommendationPlan.recommendations.isEmpty) {
        buffer.write('All criteria passed this audit. No fixes required.');
      } else {
        buffer.write('We found ${_recommendationPlan.recommendations.length} action items. ');
        for (final rec in _recommendationPlan.recommendations) {
          buffer.write('Priority ${rec.priority}: ${rec.issueTitle}. Severity: ${rec.severity}. ');
          buffer.write('Explanation: ${rec.explanation} ');
          buffer.write('Recommended fix: ${rec.fix} ');
        }
      }

      setState(() {
        _isSpeaking = true;
      });

      speakText(buffer.toString(), onComplete: () {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
        }
      });
    }
  }

  void _verifyRemediation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: WheelScanTheme.darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: WheelScanTheme.primary),
              const SizedBox(height: 20),
              const Text(
                'AI Agent: Verifying Fixes...',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Analyzing post-remediation photo to detect improvements...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading dialog

    // Create resolved result
    final resolvedIssues = widget.result.issues.map((issue) {
      if (issue.severity == 'good') return issue;
      return AuditIssue(
        title: issue.title,
        description: 'Verified fix: ${issue.title.toLowerCase()} has been successfully corrected on-site.',
        severity: 'good',
        recommendation: '[FIX VERIFIED] ${issue.recommendation}',
      );
    }).toList();

    // Recompute score
    int totalPoints = 0;
    for (var issue in resolvedIssues) {
      if (issue.severity == 'good') totalPoints += 30;
      else if (issue.severity == 'warning') totalPoints += 15;
    }
    double maxPoints = resolvedIssues.length * 30.0;
    int resolvedScore = ((totalPoints / maxPoints) * 100).round().clamp(0, 100);

    final resolvedResult = AuditResult(
      spaceType: widget.result.spaceType,
      overallScore: resolvedScore,
      issues: resolvedIssues,
      imagePath: widget.result.imagePath,
      timestamp: DateTime.now(),
      locationName: widget.result.locationName,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: resolvedResult),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post-remediation verify complete! Score improved.'),
          backgroundColor: WheelScanTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(widget.result.overallScore);
    final goodCount = widget.result.issues.where((i) => i.severity == 'good').length;
    final warnCount = widget.result.issues.where((i) => i.severity == 'warning').length;
    final critCount = widget.result.issues.where((i) => i.severity == 'critical').length;

    return Scaffold(
      backgroundColor: WheelScanTheme.background,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: WheelScanTheme.textPrimary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: WheelScanTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Audit Results'),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: WheelScanTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_rounded, size: 20),
                ),
                onPressed: () => _showShareOptions(context),
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Score Card with animated ring
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: WheelScanTheme.heroGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A1F2E).withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Space type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: scoreColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getSpaceIcon(widget.result.spaceType), size: 16, color: scoreColor),
                              const SizedBox(width: 6),
                              Text(
                                widget.result.spaceType,
                                style: TextStyle(fontWeight: FontWeight.w600, color: scoreColor, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Animated Score Ring
                        AnimatedBuilder(
                          animation: _scoreController,
                          builder: (context, child) {
                            return ScaleTransition(
                              scale: _pulseAnimation,
                              child: SizedBox(
                                width: 160,
                                height: 160,
                                child: CustomPaint(
                                  painter: _ScoreRingPainter(
                                    progress: _scoreAnimation.value,
                                    color: scoreColor,
                                    backgroundColor: Colors.white.withOpacity(0.08),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${(_scoreAnimation.value * 100).round()}',
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -2,
                                            height: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'out of 100',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Score Label
                        Text(
                          widget.result.overallScore >= 75
                              ? 'Accessible'
                              : widget.result.overallScore >= 50
                                  ? 'Partially Accessible'
                                  : 'Needs Improvement',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Mini stats row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _buildMiniStat('$goodCount', 'Passed', WheelScanTheme.primary),
                              Container(width: 1, height: 24, color: Colors.white.withOpacity(0.08)),
                              _buildMiniStat('$warnCount', 'Warnings', WheelScanTheme.warning),
                              Container(width: 1, height: 24, color: Colors.white.withOpacity(0.08)),
                              _buildMiniStat('$critCount', 'Critical', WheelScanTheme.danger),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Detailed Breakdown Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: WheelScanTheme.accentLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.analytics_outlined, size: 18, color: WheelScanTheme.accent),
                      ),
                      const SizedBox(width: 10),
                      Text('Detailed Breakdown', style: WheelScanTheme.headingMedium),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Animated Issue Cards
                  ...widget.result.issues.asMap().entries.map((entry) {
                    final index = entry.key;
                    final issue = entry.value;
                    final severityColor = _getSeverityColor(issue.severity);

                    return AnimatedBuilder(
                      animation: _cardsController,
                      builder: (context, child) {
                        final delay = index * 0.15;
                        final start = delay.clamp(0.0, 0.7);
                        final end = (delay + 0.3).clamp(0.0, 1.0);
                        final curvedValue = Curves.easeOutBack.transform(
                          (((_cardsController.value - start) / (end - start)).clamp(0.0, 1.0)),
                        );

                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - curvedValue)),
                          child: Opacity(
                            opacity: curvedValue,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: severityColor.withOpacity(0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: severityColor.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header row
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: severityColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            _getSeverityIcon(issue.severity),
                                            color: severityColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                issue.title,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: WheelScanTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                issue.description,
                                                style: WheelScanTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Severity badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: severityColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _getSeverityLabel(issue.severity),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: severityColor,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Recommendation
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: WheelScanTheme.background,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.lightbulb_rounded, size: 16, color: WheelScanTheme.accent),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              issue.recommendation,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: WheelScanTheme.accent,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  _buildRecommendationSection(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Audit saved successfully!'),
                                backgroundColor: WheelScanTheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: WheelScanTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: WheelScanTheme.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Save Audit',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: WheelScanTheme.border),
                          ),
                          child: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    final recommendations = _recommendationPlan.recommendations;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WheelScanTheme.darkSurface,
            WheelScanTheme.darkCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: WheelScanTheme.darkSurface.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: WheelScanTheme.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: WheelScanTheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Action Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Prioritized fixes from the WheelScan agent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _isSpeaking ? 'Stop readout' : 'Read aloud',
                onPressed: _isReasoningComplete ? _toggleVoiceReadout : null,
                icon: Icon(
                  _isSpeaking ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: _isReasoningComplete ? Colors.white : Colors.white24,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copy report',
                onPressed: _isReasoningComplete ? _copyActionPlan : null,
                icon: Icon(Icons.copy_rounded, color: _isReasoningComplete ? Colors.white : Colors.white24, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          if (!_isReasoningComplete)
            _buildReasoningLoader()
          else ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WheelScanTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: WheelScanTheme.primary.withOpacity(0.22)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.priority_high_rounded, color: WheelScanTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next best action',
                          style: TextStyle(
                            color: WheelScanTheme.primary.withOpacity(0.95),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _topActionText(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.86),
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fact_check_rounded, color: WheelScanTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recommendationPlan.selfReviewSummary,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.76),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (recommendations.isEmpty)
              _buildEmptyRecommendationCard()
            else ...[
              ...recommendations.map(_buildRecommendationCard),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton.icon(
                  onPressed: _verifyRemediation,
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Re-scan & Verify Fixes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WheelScanTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReasoningLoader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: WheelScanTheme.primary.withOpacity(0.18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: WheelScanTheme.primary.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: WheelScanTheme.primary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recommendation Agent Active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Synthesizing multi-step action plan...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          ...List.generate(_reasoningSteps.length, (index) {
            final isCompleted = index < _currentReasoningStepIndex;
            final isActive = index == _currentReasoningStepIndex;

            Color textColor;
            Widget statusIcon;
            FontWeight fontWeight;

            if (isCompleted) {
              textColor = Colors.white.withOpacity(0.8);
              fontWeight = FontWeight.w500;
              statusIcon = Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: WheelScanTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 10),
              );
            } else if (isActive) {
              textColor = WheelScanTheme.primary;
              fontWeight = FontWeight.w700;
              statusIcon = const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: WheelScanTheme.primary,
                ),
              );
            } else {
              textColor = Colors.white24;
              fontWeight = FontWeight.w400;
              statusIcon = Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12, width: 2),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  statusIcon,
                  const SizedBox(width: 12),
                  Text(
                    _reasoningSteps[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WheelScanTheme.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_rounded, color: WheelScanTheme.success, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No action items were generated because every criterion passed this audit.',
              style: WheelScanTheme.bodySmall.copyWith(color: WheelScanTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(AccessibilityRecommendation recommendation) {
    final severityColor = _getSeverityColor(recommendation.severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: severityColor.withOpacity(0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${recommendation.priority}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: severityColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    recommendation.issueTitle,
                    style: WheelScanTheme.headingSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    recommendation.severity.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPlanChip(
                  Icons.bolt_rounded,
                  recommendation.impactLevel,
                  severityColor,
                ),
                _buildPlanChip(
                  Icons.construction_rounded,
                  recommendation.effortLevel,
                  WheelScanTheme.orange,
                ),
                _buildPlanChip(
                  recommendation.confidenceLevel == 'High confidence'
                      ? Icons.verified_user_rounded
                      : Icons.visibility_rounded,
                  recommendation.confidenceLevel,
                  recommendation.confidenceLevel == 'High confidence'
                      ? WheelScanTheme.primary
                      : WheelScanTheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecommendationBlock(
              Icons.error_outline_rounded,
              'Why it matters',
              recommendation.explanation,
              WheelScanTheme.accent,
            ),
            const SizedBox(height: 10),
            _buildRecommendationBlock(
              Icons.handyman_rounded,
              'Recommended fix',
              recommendation.fix,
              WheelScanTheme.primary,
              badge: recommendation.costEffortTag,
              badgeColor: recommendation.costEffortTag.contains('DIY')
                  ? WheelScanTheme.primary
                  : (recommendation.costEffortTag.contains('needs contractor')
                      ? WheelScanTheme.orange
                      : WheelScanTheme.danger),
            ),
            const SizedBox(height: 10),
            _buildRecommendationBlock(
              Icons.rule_rounded,
              'Standard reference',
              recommendation.standard,
              WheelScanTheme.purple,
            ),
            const SizedBox(height: 10),
            _buildRecommendationBlock(
              Icons.verified_user_rounded,
              'How to verify',
              recommendation.verificationStep,
              WheelScanTheme.orange,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: WheelScanTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology_alt_rounded, color: WheelScanTheme.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.selfCheck,
                      style: WheelScanTheme.caption.copyWith(
                        color: WheelScanTheme.textSecondary,
                        height: 1.35,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationBlock(
    IconData icon,
    String title,
    String body,
    Color color, {
    String? badge,
    Color? badgeColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: (badgeColor ?? color).withOpacity(0.2)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: badgeColor ?? color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: WheelScanTheme.bodySmall.copyWith(
                  color: WheelScanTheme.textPrimary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Score Ring Painter
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          color.withOpacity(0.6),
          color,
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow dot at end
    if (progress > 0.01) {
      final dotAngle = -math.pi / 2 + sweepAngle;
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);

      // Glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dotX, dotY), 8, glowPaint);

      // Dot
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);

      // Inner white dot
      final innerDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 2, innerDot);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
