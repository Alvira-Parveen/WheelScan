import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../models/audit_model.dart';

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

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sharing audit report...'),
                      backgroundColor: WheelScanTheme.accent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
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