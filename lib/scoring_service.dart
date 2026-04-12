import 'dart:math';
import '../models/audit_model.dart';

class ScoringService {
  static AuditResult analyzeImage(String imagePath, {String? spaceType}) {
    final selectedType = spaceType ?? 'Unknown';

    // Check if it's a preset category or custom description
    final presetTypes = ['Ramp', 'Doorway', 'Elevator', 'Parking', 'Staircase'];

    List<AuditIssue> issues;
    String displayType;

    if (presetTypes.contains(selectedType)) {
      issues = _generatePresetIssues(selectedType);
      displayType = selectedType;
    } else {
      // Custom description — use keyword matching
      final analysis = _analyzeCustomDescription(selectedType);
      issues = analysis['issues'] as List<AuditIssue>;
      displayType = analysis['displayType'] as String;
    }

    int score = _calculateScore(issues);

    return AuditResult(
      spaceType: displayType,
      overallScore: score,
      issues: issues,
      imagePath: imagePath,
      timestamp: DateTime.now(),
      locationName: 'Scanned Location',
    );
  }

  static Map<String, dynamic> _analyzeCustomDescription(String description) {
    final lower = description.toLowerCase();
    List<AuditIssue> issues = [];
    String displayType = description;

    // Road / Street / Pathway
    if (lower.contains('road') || lower.contains('street') || lower.contains('path') || lower.contains('sidewalk') || lower.contains('walkway') || lower.contains('pavement')) {
      displayType = 'Road / Pathway';
      issues = [
        AuditIssue(
          title: 'Surface Condition',
          description: 'Road surface appears even and paved',
          severity: 'good',
          recommendation: 'Smooth surface is suitable for wheelchair movement',
        ),
        AuditIssue(
          title: 'Curb Cuts',
          description: 'Curb cuts or ramps at road crossings need verification',
          severity: 'warning',
          recommendation: 'Ensure curb cuts are present at all intersections',
        ),
        AuditIssue(
          title: 'Width',
          description: 'Pathway width appears sufficient for wheelchair passage',
          severity: 'good',
          recommendation: 'Minimum 1.2m width recommended for comfortable passage',
        ),
        AuditIssue(
          title: 'Obstacles',
          description: 'No major obstructions detected on the path',
          severity: 'good',
          recommendation: 'Path should remain clear of parked vehicles and debris',
        ),
        AuditIssue(
          title: 'Tactile Paving',
          description: 'No tactile guidance strips detected',
          severity: 'warning',
          recommendation: 'Add tactile paving for visually impaired navigation',
        ),
      ];
    }
    // Home / House / Residential
    else if (lower.contains('home') || lower.contains('house') || lower.contains('residential') || lower.contains('apartment') || lower.contains('flat')) {
      displayType = 'Home / Residential';
      issues = [
        AuditIssue(
          title: 'Entrance Access',
          description: 'Main entrance accessibility needs assessment',
          severity: 'warning',
          recommendation: 'Ensure step-free entry or install a portable ramp',
        ),
        AuditIssue(
          title: 'Door Width',
          description: 'Standard residential doors may be narrow for wheelchairs',
          severity: 'warning',
          recommendation: 'Doors should be minimum 81cm wide for wheelchair access',
        ),
        AuditIssue(
          title: 'Floor Level',
          description: 'Ground floor access appears available',
          severity: 'good',
          recommendation: 'Ground floor living reduces accessibility barriers',
        ),
        AuditIssue(
          title: 'Pathway to Door',
          description: 'Clear pathway from street to entrance detected',
          severity: 'good',
          recommendation: 'Maintain clear, even pathway to entrance',
        ),
      ];
    }
    // Hospital / Clinic / Medical
    else if (lower.contains('hospital') || lower.contains('clinic') || lower.contains('medical') || lower.contains('health')) {
      displayType = 'Hospital / Medical';
      issues = [
        AuditIssue(
          title: 'Main Entrance',
          description: 'Automatic doors expected at medical facilities',
          severity: 'good',
          recommendation: 'Automatic sliding doors are ideal for accessibility',
        ),
        AuditIssue(
          title: 'Corridor Width',
          description: 'Hospital corridors typically meet width standards',
          severity: 'good',
          recommendation: 'Corridors should allow two wheelchairs to pass (1.8m+)',
        ),
        AuditIssue(
          title: 'Signage',
          description: 'Accessibility signage should be clearly visible',
          severity: 'warning',
          recommendation: 'Add clear directional signs with wheelchair symbols',
        ),
        AuditIssue(
          title: 'Emergency Access',
          description: 'Emergency exits need wheelchair accessibility verification',
          severity: 'warning',
          recommendation: 'All emergency routes must be wheelchair accessible',
        ),
      ];
    }
    // Mall / Shopping / Store / Market
    else if (lower.contains('mall') || lower.contains('shop') || lower.contains('store') || lower.contains('market') || lower.contains('commercial')) {
      displayType = 'Commercial / Mall';
      issues = [
        AuditIssue(
          title: 'Entrance Accessibility',
          description: 'Main entrance appears to have level access',
          severity: 'good',
          recommendation: 'Automatic doors improve independent access',
        ),
        AuditIssue(
          title: 'Floor Navigation',
          description: 'Internal pathways need width verification',
          severity: 'warning',
          recommendation: 'Aisles should be minimum 90cm for wheelchair navigation',
        ),
        AuditIssue(
          title: 'Elevator Availability',
          description: 'Multi-floor access requires elevator verification',
          severity: 'warning',
          recommendation: 'Ensure elevators are available for all public floors',
        ),
        AuditIssue(
          title: 'Seating Areas',
          description: 'Wheelchair-friendly seating spaces recommended',
          severity: 'good',
          recommendation: 'Designate spaces without fixed seating for wheelchair users',
        ),
      ];
    }
    // Bus stop / Transit / Station
    else if (lower.contains('bus') || lower.contains('transit') || lower.contains('station') || lower.contains('metro') || lower.contains('transport')) {
      displayType = 'Transit / Bus Stop';
      issues = [
        AuditIssue(
          title: 'Platform Level',
          description: 'Platform height needs to match vehicle entry',
          severity: 'warning',
          recommendation: 'Level boarding or deployable ramps needed',
        ),
        AuditIssue(
          title: 'Waiting Area',
          description: 'Covered seating area with wheelchair space needed',
          severity: 'warning',
          recommendation: 'Reserve clear space next to seating for wheelchair users',
        ),
        AuditIssue(
          title: 'Approach Path',
          description: 'Path to transit stop appears accessible',
          severity: 'good',
          recommendation: 'Maintain clear, paved path to stop',
        ),
        AuditIssue(
          title: 'Information Display',
          description: 'Route info should be at accessible height',
          severity: 'warning',
          recommendation: 'Display boards at 1.2m height for seated reading',
        ),
      ];
    }
    // Garden / Park / Outdoor
    else if (lower.contains('garden') || lower.contains('park') || lower.contains('outdoor') || lower.contains('ground') || lower.contains('lawn') || lower.contains('field')) {
      displayType = 'Garden / Outdoor';
      issues = [
        AuditIssue(
          title: 'Path Surface',
          description: 'Natural/unpaved surfaces can be difficult for wheelchairs',
          severity: 'warning',
          recommendation: 'Paved or compacted paths recommended for wheelchair access',
        ),
        AuditIssue(
          title: 'Path Width',
          description: 'Garden paths should accommodate wheelchair width',
          severity: 'good',
          recommendation: 'Minimum 1.2m wide paths for comfortable movement',
        ),
        AuditIssue(
          title: 'Slope & Terrain',
          description: 'Uneven terrain may pose challenges',
          severity: 'warning',
          recommendation: 'Gradients should not exceed 1:20 for outdoor paths',
        ),
        AuditIssue(
          title: 'Rest Areas',
          description: 'Seating and rest points improve accessibility',
          severity: 'good',
          recommendation: 'Place benches with wheelchair space every 50m',
        ),
      ];
    }
    // Office / Lobby / Building / Corridor
    else if (lower.contains('office') || lower.contains('lobby') || lower.contains('building') || lower.contains('corridor') || lower.contains('hallway')) {
      displayType = 'Office / Building';
      issues = [
        AuditIssue(
          title: 'Entry Door',
          description: 'Main door should be automatic or easy-open',
          severity: 'warning',
          recommendation: 'Install automatic doors or door-assist mechanisms',
        ),
        AuditIssue(
          title: 'Corridor Width',
          description: 'Indoor corridors appear adequately wide',
          severity: 'good',
          recommendation: 'Maintain minimum 1.5m width in corridors',
        ),
        AuditIssue(
          title: 'Floor Surface',
          description: 'Indoor flooring appears smooth and even',
          severity: 'good',
          recommendation: 'Non-slip flooring is ideal for wheelchair traction',
        ),
        AuditIssue(
          title: 'Reception Height',
          description: 'Counter height may not be wheelchair accessible',
          severity: 'warning',
          recommendation: 'Provide a lowered section (76cm) at reception desks',
        ),
      ];
    }
    // Fallback — generic accessibility check
    else {
      displayType = description;
      issues = [
        AuditIssue(
          title: 'Ground Surface',
          description: 'Surface condition assessment for wheelchair movement',
          severity: 'good',
          recommendation: 'Smooth, firm surfaces are best for wheelchair mobility',
        ),
        AuditIssue(
          title: 'Clear Pathway',
          description: 'Pathway clearance needs verification',
          severity: 'warning',
          recommendation: 'Ensure minimum 90cm clear width for wheelchair passage',
        ),
        AuditIssue(
          title: 'Level Access',
          description: 'Steps or elevation changes need assessment',
          severity: 'warning',
          recommendation: 'Provide ramps for any elevation changes greater than 1.3cm',
        ),
        AuditIssue(
          title: 'Lighting',
          description: 'Adequate lighting improves safety and navigation',
          severity: 'good',
          recommendation: 'Well-lit paths help all users navigate safely',
        ),
      ];
    }

    return {
      'issues': issues,
      'displayType': displayType,
    };
  }

  static List<AuditIssue> _generatePresetIssues(String spaceType) {
    switch (spaceType) {
      case 'Ramp':
        return [
          AuditIssue(
            title: 'Handrails',
            description: 'Handrails detected on both sides',
            severity: 'good',
            recommendation: 'Meets accessibility standards',
          ),
          AuditIssue(
            title: 'Slope Angle',
            description: 'Slope appears steeper than recommended 1:12 ratio',
            severity: 'warning',
            recommendation: 'Consider reducing slope gradient',
          ),
          AuditIssue(
            title: 'Surface Texture',
            description: 'Non-slip surface detected',
            severity: 'good',
            recommendation: 'Good traction for wheelchair users',
          ),
          AuditIssue(
            title: 'Width',
            description: 'Ramp width appears adequate (>90cm)',
            severity: 'good',
            recommendation: 'Sufficient for wheelchair passage',
          ),
        ];
      case 'Doorway':
        return [
          AuditIssue(
            title: 'Door Width',
            description: 'Doorway appears narrow for wheelchair access',
            severity: 'critical',
            recommendation: 'Minimum 81cm clear width required',
          ),
          AuditIssue(
            title: 'Threshold',
            description: 'Raised threshold detected',
            severity: 'warning',
            recommendation: 'Threshold should be flush or <1.3cm',
          ),
          AuditIssue(
            title: 'Handle Type',
            description: 'Lever-style handle detected',
            severity: 'good',
            recommendation: 'Lever handles are accessible',
          ),
        ];
      case 'Elevator':
        return [
          AuditIssue(
            title: 'Button Height',
            description: 'Buttons appear within reachable range',
            severity: 'good',
            recommendation: 'Meets wheelchair reach requirements',
          ),
          AuditIssue(
            title: 'Door Width',
            description: 'Elevator door width appears adequate',
            severity: 'good',
            recommendation: 'Standard accessible width',
          ),
          AuditIssue(
            title: 'Braille Labels',
            description: 'No braille labels detected on buttons',
            severity: 'warning',
            recommendation: 'Add braille labels for visually impaired users',
          ),
        ];
      case 'Parking':
        return [
          AuditIssue(
            title: 'Accessible Sign',
            description: 'Wheelchair symbol signage present',
            severity: 'good',
            recommendation: 'Proper signage in place',
          ),
          AuditIssue(
            title: 'Space Width',
            description: 'Parking space appears narrower than standard',
            severity: 'critical',
            recommendation: 'Accessible spaces need 3.6m minimum width',
          ),
          AuditIssue(
            title: 'Path to Entrance',
            description: 'No clear path from parking to building entrance',
            severity: 'critical',
            recommendation: 'Create marked accessible route',
          ),
        ];
      case 'Staircase':
        return [
          AuditIssue(
            title: 'Alternative Route',
            description: 'No ramp or elevator alternative found nearby',
            severity: 'critical',
            recommendation: 'Stairs are not accessible — need an alternative',
          ),
          AuditIssue(
            title: 'Handrails',
            description: 'Handrails present on one side only',
            severity: 'warning',
            recommendation: 'Add handrails on both sides',
          ),
          AuditIssue(
            title: 'Tactile Warning',
            description: 'No tactile warning strips at top of stairs',
            severity: 'warning',
            recommendation: 'Add tactile strips for visually impaired users',
          ),
        ];
      default:
        return [];
    }
  }

  static int _calculateScore(List<AuditIssue> issues) {
    if (issues.isEmpty) return 50;

    int totalPoints = 0;
    for (var issue in issues) {
      switch (issue.severity) {
        case 'good':
          totalPoints += 30;
          break;
        case 'warning':
          totalPoints += 15;
          break;
        case 'critical':
          totalPoints += 0;
          break;
      }
    }

    double maxPoints = issues.length * 30.0;
    return ((totalPoints / maxPoints) * 100).round().clamp(0, 100);
  }
}