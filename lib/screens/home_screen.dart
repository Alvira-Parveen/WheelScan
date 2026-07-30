import 'package:flutter/material.dart';
import '../config/theme.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onMapTap;
  final VoidCallback? onFeedTap;
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onScanTap,
    this.onMapTap,
    this.onFeedTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: WheelScanTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good afternoon', style: WheelScanTheme.caption),
                      const SizedBox(height: 1),
                      Text('Alvira Parveen', style: WheelScanTheme.headingSmall),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WheelScanTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dark Hero Card — tappable
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: WheelScanTheme.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1F2E).withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: WheelScanTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: WheelScanTheme.primary.withOpacity(0.25),
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: WheelScanTheme.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start New Scan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Scan any public space to check\nwheelchair accessibility instantly',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Scan button — connected
                    GestureDetector(
                      onTap: onScanTap,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: WheelScanTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: WheelScanTheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Scan Now',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _buildDarkStat('24', 'Scans'),
                          _buildDarkDivider(),
                          _buildDarkStat('72', 'Avg Score'),
                          _buildDarkDivider(),
                          _buildDarkStat('12', 'Places'),
                          _buildDarkDivider(),
                          _buildDarkStat('7', 'Streak'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Quick Scan Categories — each tappable
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Quick Scan', style: WheelScanTheme.headingMedium),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryChip('Ramp', Icons.accessibility_new, WheelScanTheme.primary, WheelScanTheme.primaryLight, onScanTap),
                  _buildCategoryChip('Doorway', Icons.door_front_door, WheelScanTheme.accent, WheelScanTheme.accentLight, onScanTap),
                  _buildCategoryChip('Elevator', Icons.elevator, WheelScanTheme.purple, WheelScanTheme.purpleLight, onScanTap),
                  _buildCategoryChip('Parking', Icons.local_parking, WheelScanTheme.orange, WheelScanTheme.orangeLight, onScanTap),
                  _buildCategoryChip('Stairs', Icons.stairs, WheelScanTheme.danger, WheelScanTheme.dangerLight, onScanTap),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Impact Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildImpactCard('5', 'Issues Found', Icons.bug_report_outlined, WheelScanTheme.danger, WheelScanTheme.dangerLight),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImpactCard('3', 'Improved', Icons.trending_up_rounded, WheelScanTheme.primary, WheelScanTheme.primaryLight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Recent Audits
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Audits', style: WheelScanTheme.headingMedium),
                  GestureDetector(
                    onTap: onFeedTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: WheelScanTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: WheelScanTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildAuditCard('Main Library Entrance', 'Ramp', 85, '2 hrs ago', Icons.accessibility_new),
                  _buildAuditCard('Cafeteria Parking', 'Parking', 62, '5 hrs ago', Icons.local_parking),
                  _buildAuditCard('Admin Block Stairs', 'Staircase', 34, 'Yesterday', Icons.stairs),
                  _buildAuditCard('Science Block Elevator', 'Elevator', 89, 'Yesterday', Icons.elevator),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tip Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: onMapTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WheelScanTheme.primary.withOpacity(0.08),
                        WheelScanTheme.accent.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: WheelScanTheme.primary.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: WheelScanTheme.shimmerGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Accessibility Map',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: WheelScanTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'See all audited locations near you on the map',
                              style: WheelScanTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: WheelScanTheme.textMuted),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  static Widget _buildDarkStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDarkDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.08),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, Color color, Color bgColor, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: WheelScanTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactCard(String value, String label, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: WheelScanTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditCard(String name, String type, int score, String time, IconData icon) {
    Color scoreColor;
    Color scoreBg;
    if (score >= 75) {
      scoreColor = WheelScanTheme.primary;
      scoreBg = WheelScanTheme.primaryLight;
    } else if (score >= 50) {
      scoreColor = WheelScanTheme.warning;
      scoreBg = WheelScanTheme.warningLight;
    } else {
      scoreColor = WheelScanTheme.danger;
      scoreBg = WheelScanTheme.dangerLight;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WheelScanTheme.border.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scoreBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: scoreColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: scoreBg,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreBg,
                border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}