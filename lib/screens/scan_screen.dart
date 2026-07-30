import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../services/scoring_service.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _scanImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      if (mounted) {
        final spaceType = await _showSpaceTypeSelector();
        if (spaceType == null) return;

        setState(() {
          _isAnalyzing = true;
        });

        await Future.delayed(const Duration(seconds: 2));

        final result = ScoringService.analyzeImage(image.path, spaceType: spaceType);

        setState(() {
          _isAnalyzing = false;
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(result: result),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String?> _showSpaceTypeSelector() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'What type of space is this?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: WheelScanTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select the category for accurate analysis',
                style: TextStyle(
                  fontSize: 13,
                  color: WheelScanTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSpaceOption(sheetContext, 'Ramp', Icons.accessibility_new, 'Wheelchair ramps & slopes'),
              _buildSpaceOption(sheetContext, 'Doorway', Icons.door_front_door, 'Entrances & doorways'),
              _buildSpaceOption(sheetContext, 'Elevator', Icons.elevator, 'Lifts & elevators'),
              _buildSpaceOption(sheetContext, 'Parking', Icons.local_parking, 'Parking areas & lots'),
              _buildSpaceOption(sheetContext, 'Staircase', Icons.stairs, 'Stairs & step areas'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WheelScanTheme.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final customType = await _showCustomDescriptionDialog();
                  if (customType != null && customType.isNotEmpty) {
                    _processCustomScan(customType);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WheelScanTheme.accent.withOpacity(0.05),
                        WheelScanTheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WheelScanTheme.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: WheelScanTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.edit_note, color: WheelScanTheme.accent, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Describe the Space',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: WheelScanTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Type what you see — road, corridor, entrance, etc.',
                              style: TextStyle(
                                fontSize: 12,
                                color: WheelScanTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: WheelScanTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _processCustomScan(String customType) async {
    setState(() {
      _isAnalyzing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final result = ScoringService.analyzeImage('custom', spaceType: customType);

    setState(() {
      _isAnalyzing = false;
    });

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: result),
        ),
      );
    }
  }

  Future<String?> _showCustomDescriptionDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Describe the Space',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: WheelScanTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Describe what you see in the image. Be specific for better results.',
                style: TextStyle(
                  fontSize: 13,
                  color: WheelScanTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g., Road area near apartments, hospital corridor, mall entrance...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: WheelScanTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: WheelScanTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildSuggestionChip(controller, 'Road area'),
                  _buildSuggestionChip(controller, 'Home entrance'),
                  _buildSuggestionChip(controller, 'Hospital corridor'),
                  _buildSuggestionChip(controller, 'Mall pathway'),
                  _buildSuggestionChip(controller, 'Sidewalk'),
                  _buildSuggestionChip(controller, 'Bus stop'),
                  _buildSuggestionChip(controller, 'Garden path'),
                  _buildSuggestionChip(controller, 'Office lobby'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: WheelScanTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WheelScanTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Analyze'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestionChip(TextEditingController controller, String text) {
    return GestureDetector(
      onTap: () {
        controller.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: WheelScanTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: WheelScanTheme.primary.withOpacity(0.2)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: WheelScanTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceOption(BuildContext ctx, String type, IconData icon, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.pop(ctx, type),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: WheelScanTheme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: WheelScanTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: WheelScanTheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WheelScanTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: WheelScanTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: WheelScanTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isAnalyzing ? _buildAnalyzingView() : _buildScanView(),
    );
  }

  Widget _buildScanView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Scan a Space',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: WheelScanTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or upload an image of any\npublic space to check accessibility',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: WheelScanTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildScanOptionCard(
            icon: Icons.camera_alt,
            title: 'Take a Photo',
            subtitle: 'Use your camera to capture the space',
            color: WheelScanTheme.primary,
            onTap: () => _scanImage(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          _buildScanOptionCard(
            icon: Icons.photo_library,
            title: 'Upload from Gallery',
            subtitle: 'Select an existing photo from your device',
            color: WheelScanTheme.accent,
            onTap: () => _scanImage(ImageSource.gallery),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WheelScanTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WheelScanTheme.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates, size: 18, color: WheelScanTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tips for best results',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: WheelScanTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTip('Capture the full ramp, doorway, or entrance'),
                _buildTip('Ensure good lighting for clear analysis'),
                _buildTip('Include surrounding context (handrails, signs)'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScanOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: WheelScanTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: WheelScanTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: WheelScanTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: WheelScanTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(WheelScanTheme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Analyzing Space...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: WheelScanTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Checking accessibility features',
            style: TextStyle(
              fontSize: 14,
              color: WheelScanTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: WheelScanTheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: WheelScanTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}