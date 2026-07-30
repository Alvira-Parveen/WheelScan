import 'package:flutter/material.dart';
import '../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'English';

  void _showEditProfile() {
    final nameController = TextEditingController(text: 'Alvira Parveen');
    final emailController = TextEditingController(text: 'alvira@example.com');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Profile', style: WheelScanTheme.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar edit
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: WheelScanTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('A', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: WheelScanTheme.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: WheelScanTheme.textSecondary, fontSize: 13),
                filled: true,
                fillColor: WheelScanTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: WheelScanTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: WheelScanTheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: WheelScanTheme.textSecondary, fontSize: 13),
                filled: true,
                fillColor: WheelScanTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: WheelScanTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: WheelScanTheme.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: WheelScanTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile updated successfully!'),
                  backgroundColor: WheelScanTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WheelScanTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsToggle() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Notification Settings', style: WheelScanTheme.headingMedium),
              const SizedBox(height: 20),
              _buildToggleRow('Push Notifications', 'Get alerts for new audits nearby', _notifications, (val) {
                setSheetState(() => _notifications = val);
                setState(() => _notifications = val);
              }),
              const SizedBox(height: 12),
              _buildToggleRow('Community Updates', 'When someone audits near you', true, (val) {}),
              const SizedBox(height: 12),
              _buildToggleRow('Weekly Report', 'Your weekly accessibility impact', true, (val) {}),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: WheelScanTheme.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: WheelScanTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: WheelScanTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: WheelScanTheme.primary,
          ),
        ],
      ),
    );
  }

  void _showDarkModeToggle() {
    setState(() => _darkMode = !_darkMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_darkMode ? 'Dark mode enabled (coming soon!)' : 'Light mode active'),
        backgroundColor: _darkMode ? const Color(0xFF1A1F2E) : WheelScanTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Select Language', style: WheelScanTheme.headingMedium),
            const SizedBox(height: 16),
            _buildLanguageOption('English', '🇬🇧'),
            _buildLanguageOption('Hindi', '🇮🇳'),
            _buildLanguageOption('Spanish', '🇪🇸'),
            _buildLanguageOption('French', '🇫🇷'),
            _buildLanguageOption('Arabic', '🇸🇦'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    final isSelected = _language == language;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _language = language);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Language set to $language'),
              backgroundColor: WheelScanTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? WheelScanTheme.primaryLight : WheelScanTheme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? WheelScanTheme.primary.withOpacity(0.3) : Colors.transparent),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(language, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: WheelScanTheme.textPrimary)),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle, color: WheelScanTheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Help & Support', style: WheelScanTheme.headingMedium),
            const SizedBox(height: 16),
            _buildHelpItem(Icons.question_answer_outlined, 'FAQ', 'Frequently asked questions'),
            _buildHelpItem(Icons.email_outlined, 'Contact Us', 'support@wheelscan.app'),
            _buildHelpItem(Icons.feedback_outlined, 'Send Feedback', 'Help us improve WheelScan'),
            _buildHelpItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: WheelScanTheme.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: WheelScanTheme.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: WheelScanTheme.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: WheelScanTheme.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: WheelScanTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: WheelScanTheme.textMuted),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: WheelScanTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.accessible, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text('WheelScan', style: WheelScanTheme.headingLarge),
            const SizedBox(height: 4),
            Text('Version 1.0.0', style: TextStyle(fontSize: 13, color: WheelScanTheme.textSecondary)),
            const SizedBox(height: 16),
            Text(
              'AI-powered accessibility auditor that helps make public spaces more inclusive for wheelchair users and people with mobility challenges.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: WheelScanTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WheelScanTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code, size: 16, color: WheelScanTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Built with Flutter & Dart',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WheelScanTheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Made by Alvira Parveen',
              style: TextStyle(fontSize: 11, color: WheelScanTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: WheelScanTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: WheelScanTheme.headingMedium),
        content: Text(
          'Are you sure you want to log out? Your audit data will be saved.',
          style: TextStyle(fontSize: 14, color: WheelScanTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: WheelScanTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Logged out successfully'),
                  backgroundColor: WheelScanTheme.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WheelScanTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: WheelScanTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: WheelScanTheme.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('A', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Alvira Parveen', style: WheelScanTheme.headingLarge),
                  const SizedBox(height: 4),
                  Text('Accessibility Advocate', style: WheelScanTheme.bodySmall),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: WheelScanTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Member since Apr 2026',
                      style: TextStyle(fontSize: 11, color: WheelScanTheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Stats Row
            Container(
              padding: const EdgeInsets.all(20),
              decoration: WheelScanTheme.cardDecoration,
              child: Row(
                children: [
                  Expanded(child: _buildStat('24', 'Audits')),
                  Container(width: 1, height: 40, color: WheelScanTheme.border),
                  Expanded(child: _buildStat('72', 'Avg Score')),
                  Container(width: 1, height: 40, color: WheelScanTheme.border),
                  Expanded(child: _buildStat('12', 'Places')),
                  Container(width: 1, height: 40, color: WheelScanTheme.border),
                  Expanded(child: _buildStat('5', 'Badges')),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Badges
            Text('Badges Earned', style: WheelScanTheme.headingMedium),
            const SizedBox(height: 14),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildBadge('First Scan', Icons.camera_alt, WheelScanTheme.primary, true),
                  _buildBadge('5 Audits', Icons.star, WheelScanTheme.warning, true),
                  _buildBadge('Ramp Expert', Icons.accessibility_new, WheelScanTheme.accent, true),
                  _buildBadge('10 Audits', Icons.military_tech, WheelScanTheme.purple, true),
                  _buildBadge('All Types', Icons.grid_view, Colors.teal, true),
                  _buildBadge('50 Audits', Icons.emoji_events, Colors.grey.shade400, false),
                  _buildBadge('Champion', Icons.workspace_premium, Colors.grey.shade400, false),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Streak
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [WheelScanTheme.primary.withOpacity(0.08), WheelScanTheme.accent.withOpacity(0.08)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WheelScanTheme.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: WheelScanTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.local_fire_department, color: WheelScanTheme.warning, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('7 Day Streak!', style: WheelScanTheme.headingSmall),
                        const SizedBox(height: 2),
                        Text('You\'ve scanned every day this week!', style: WheelScanTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Audit History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Audit History', style: WheelScanTheme.headingMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: WheelScanTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: WheelScanTheme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 14, color: WheelScanTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('All', style: TextStyle(fontSize: 12, color: WheelScanTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildHistoryItem('Main Library Entrance', 'Ramp', 85, 'Apr 6, 2026', Icons.accessibility_new, WheelScanTheme.primary),
            _buildHistoryItem('Cafeteria Parking', 'Parking', 62, 'Apr 5, 2026', Icons.local_parking, WheelScanTheme.warning),
            _buildHistoryItem('Admin Block Stairs', 'Staircase', 34, 'Apr 5, 2026', Icons.stairs, WheelScanTheme.danger),
            _buildHistoryItem('Science Block Elevator', 'Elevator', 89, 'Apr 4, 2026', Icons.elevator, WheelScanTheme.primary),
            _buildHistoryItem('Gate 2 Entrance', 'Doorway', 71, 'Apr 4, 2026', Icons.door_front_door, WheelScanTheme.warning),
            _buildHistoryItem('Campus Road', 'Road / Pathway', 80, 'Apr 3, 2026', Icons.route, WheelScanTheme.primary),

            const SizedBox(height: 28),

            // Settings
            Text('Settings', style: WheelScanTheme.headingMedium),
            const SizedBox(height: 14),
            _buildSettingsItem(Icons.person_outline, 'Edit Profile', onTap: _showEditProfile),
            _buildSettingsItem(Icons.notifications_outlined, 'Notifications', trailing: _notifications ? 'On' : 'Off', onTap: _showNotificationsToggle),
            _buildSettingsItem(Icons.dark_mode_outlined, 'Dark Mode', trailing: _darkMode ? 'On' : 'Off', onTap: _showDarkModeToggle),
            _buildSettingsItem(Icons.language, 'Language', trailing: _language, onTap: _showLanguageSelector),
            _buildSettingsItem(Icons.help_outline, 'Help & Support', onTap: _showHelpSupport),
            _buildSettingsItem(Icons.info_outline, 'About WheelScan', onTap: _showAbout),
            const SizedBox(height: 10),
            _buildSettingsItem(Icons.logout, 'Log Out', isDestructive: true, onTap: _showLogout),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: WheelScanTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: WheelScanTheme.textSecondary)),
      ],
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color, bool earned) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(earned ? '$label badge earned!' : '$label — keep scanning to unlock!'),
              backgroundColor: earned ? WheelScanTheme.primary : WheelScanTheme.textSecondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: earned ? color.withOpacity(0.12) : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: earned ? color.withOpacity(0.3) : Colors.grey.shade300, width: 2),
              ),
              child: Icon(icon, color: earned ? color : Colors.grey.shade400, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: earned ? WheelScanTheme.textPrimary : Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String name, String type, int score, String date, IconData icon, Color scoreColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: scoreColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: scoreColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: WheelScanTheme.textPrimary)),
                  const SizedBox(height: 3),
                  Text('$type  •  $date', style: TextStyle(fontSize: 11, color: WheelScanTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: scoreColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('$score', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: scoreColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String label, {bool isDestructive = false, String? trailing, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isDestructive ? WheelScanTheme.danger : WheelScanTheme.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? WheelScanTheme.danger : WheelScanTheme.textPrimary),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(trailing, style: TextStyle(fontSize: 12, color: WheelScanTheme.textMuted)),
                ),
              Icon(Icons.chevron_right, size: 18, color: isDestructive ? WheelScanTheme.danger.withOpacity(0.5) : Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}