import '../models/audit_model.dart';

class RecommendationAgentService {
  static RecommendationPlan buildPlan(AuditResult result) {
    final flaggedIssues = result.issues
        .where((issue) => issue.severity == 'warning' || issue.severity == 'critical')
        .toList()
      ..sort(_compareSeverity);

    final generated = <AccessibilityRecommendation>[];

    for (final issue in flaggedIssues) {
      final draft = _generateRecommendation(
        result.spaceType,
        issue,
        generated.length + 1,
      );
      generated.add(_selfReview(draft, result.spaceType));
    }

    return RecommendationPlan(
      spaceType: result.spaceType,
      recommendations: generated,
      selfReviewSummary: generated.isEmpty
          ? 'Agent check complete: no warning or critical criteria were found in this audit.'
          : 'Agent check complete: each recommendation includes the barrier, a concrete fix, a priority rank, and a standards reference where available.',
    );
  }

  static int _compareSeverity(AuditIssue a, AuditIssue b) {
    return _severityWeight(b.severity).compareTo(_severityWeight(a.severity));
  }

  static int _severityWeight(String severity) {
    switch (severity) {
      case 'critical':
        return 2;
      case 'warning':
        return 1;
      default:
        return 0;
    }
  }

  static AccessibilityRecommendation _generateRecommendation(
    String spaceType,
    AuditIssue issue,
    int priority,
  ) {
    final key = '${spaceType.toLowerCase()}|${issue.title.toLowerCase()}';
    final guidance = _guidanceLibrary[key] ??
        _guidanceLibrary['any|${issue.title.toLowerCase()}'] ??
        _fallbackGuidance(spaceType, issue);

    return AccessibilityRecommendation(
      priority: priority,
      issueTitle: issue.title,
      severity: issue.severity,
      impactLevel: _impactLevel(issue),
      effortLevel: _effortLevel(issue),
      explanation: guidance.explanation,
      fix: guidance.fix,
      standard: guidance.standard,
      verificationStep: _verificationStep(spaceType, issue),
      selfCheck: 'Draft generated from ${issue.severity.toUpperCase()} criterion and checked for actionability.',
      confidenceLevel: _confidenceLevel(issue),
      costEffortTag: _costEffortTag(issue),
    );
  }

  static AccessibilityRecommendation _selfReview(
    AccessibilityRecommendation draft,
    String spaceType,
  ) {
    var explanation = draft.explanation.trim();
    var fix = draft.fix.trim();
    var selfCheck = draft.selfCheck;

    if (_isVague(fix)) {
      fix = 'Measure the ${draft.issueTitle.toLowerCase()} in this $spaceType area, document the barrier, and apply the listed accessibility standard before reopening the space for independent use.';
      selfCheck = '$selfCheck Rewritten because the first fix was too generic.';
    }

    if (_isVague(explanation)) {
      explanation = 'This ${draft.issueTitle.toLowerCase()} issue can block independent access in a $spaceType area, especially for wheelchair users, older adults, and people with low vision.';
      selfCheck = '$selfCheck Explanation refined to describe the user impact.';
    }

    return AccessibilityRecommendation(
      priority: draft.priority,
      issueTitle: draft.issueTitle,
      severity: draft.severity,
      impactLevel: draft.impactLevel,
      effortLevel: draft.effortLevel,
      explanation: explanation,
      fix: fix,
      standard: draft.standard,
      verificationStep: draft.verificationStep,
      selfCheck: selfCheck,
      confidenceLevel: draft.confidenceLevel,
      costEffortTag: draft.costEffortTag,
    );
  }

  static String _confidenceLevel(AuditIssue issue) {
    final title = issue.title.toLowerCase();
    final desc = issue.description.toLowerCase();
    if (title.contains('slope') ||
        title.contains('width') ||
        title.contains('threshold') ||
        title.contains('handrails') ||
        title.contains('surface') ||
        desc.contains('appears') ||
        desc.contains('seems') ||
        desc.contains('may be')) {
      return 'Verify on-site';
    }
    return 'High confidence';
  }

  static String _costEffortTag(AuditIssue issue) {
    final title = issue.title.toLowerCase();
    if (title.contains('braille') ||
        title.contains('signage') ||
        title.contains('lighting') ||
        title.contains('display') ||
        title.contains('obstacle') ||
        title.contains('surface texture') ||
        title.contains('seating')) {
      return 'Low cost — DIY';
    }
    if (title.contains('handrails') ||
        title.contains('tactile warning') ||
        title.contains('tactile paving') ||
        title.contains('threshold') ||
        title.contains('curb cuts') ||
        title.contains('entry door') ||
        title.contains('reception')) {
      return 'Medium — needs contractor';
    }
    if (title.contains('slope') ||
        title.contains('door width') ||
        title.contains('alternative route') ||
        title.contains('elevator') ||
        title.contains('parking') ||
        title.contains('entrance access') ||
        title.contains('path to entrance')) {
      return 'High — structural change';
    }
    return 'Medium — needs contractor';
  }

  static String _impactLevel(AuditIssue issue) {
    if (issue.severity == 'critical') return 'High access impact';

    final title = issue.title.toLowerCase();
    if (title.contains('tactile') ||
        title.contains('braille') ||
        title.contains('emergency') ||
        title.contains('platform')) {
      return 'High safety impact';
    }
    return 'Medium access impact';
  }

  static String _effortLevel(AuditIssue issue) {
    final title = issue.title.toLowerCase();
    if (title.contains('signage') ||
        title.contains('tactile') ||
        title.contains('braille') ||
        title.contains('information')) {
      return 'Low-medium effort';
    }
    if (title.contains('slope') ||
        title.contains('width') ||
        title.contains('route') ||
        title.contains('elevator') ||
        title.contains('platform')) {
      return 'High effort';
    }
    return 'Medium effort';
  }

  static String _verificationStep(String spaceType, AuditIssue issue) {
    final title = issue.title.toLowerCase();
    if (title.contains('slope')) {
      return 'Measure the ramp gradient after changes and confirm the slope is 1:12 or gentler before marking the route accessible.';
    }
    if (title.contains('door width')) {
      return 'Measure the clear opening with the door fully open and confirm at least 32 inches / 815 mm of usable width.';
    }
    if (title.contains('threshold')) {
      return 'Measure the level change at the entry and confirm it is flush or below 13 mm with a beveled edge.';
    }
    if (title.contains('handrails')) {
      return 'Walk the full stair flight and confirm handrails are continuous, firm, easy to grip, and present on both sides.';
    }
    if (title.contains('tactile')) {
      return 'Check that tactile indicators are installed before the first step or hazard zone and are detectable underfoot.';
    }
    if (title.contains('route') || title.contains('path')) {
      return 'Follow the route from start to finish using a wheelchair-width path check, confirming there are no steps, blocked points, or unsafe crossings.';
    }
    if (title.contains('signage')) {
      return 'Stand at the decision point and confirm the sign is readable, high contrast, and points to the accessible route.';
    }
    if (title.contains('parking')) {
      return 'Measure the marked bay and access aisle, then confirm the path from the bay to the entrance is step-free.';
    }
    return 'Re-scan the same $spaceType area after the fix and compare the updated score against this audit.';
  }

  static bool _isVague(String text) {
    final lower = text.toLowerCase();
    return lower.length < 40 ||
        lower == 'meets accessibility standards' ||
        lower.contains('consider improving') ||
        lower.contains('fix accessibility issue');
  }

  static _Guidance _fallbackGuidance(String spaceType, AuditIssue issue) {
    return _Guidance(
      explanation: '${issue.description}. In a $spaceType audit, this matters because the barrier can reduce safe, independent movement through the space.',
      fix: '${issue.recommendation}. Assign this as a site correction task, verify the measurement on-site, and re-scan the same area after the change.',
      standard: 'Use Harmonised Guidelines and Standards for Universal Accessibility in India, plus WCAG-style clear communication for public guidance.',
    );
  }

  static const Map<String, _Guidance> _guidanceLibrary = {
    'ramp|slope angle': _Guidance(
      explanation: 'The ramp appears steeper than the recommended gradient. A steep ramp can make wheelchair ascent exhausting and descent unsafe without assistance.',
      fix: 'Rebuild or extend the ramp run so the slope is 1:12 or gentler. Add level landings at the top and bottom, and add intermediate landings for longer ramp runs.',
      standard: 'Ramp gradient: 1:12 or gentler is the commonly used accessibility target.',
    ),
    'doorway|door width': _Guidance(
      explanation: 'The doorway appears too narrow for comfortable wheelchair entry. This can completely block independent access even when the rest of the space is usable.',
      fix: 'Increase the clear opening width to at least 32 inches / 815 mm. Remove obstructions from the swing area and re-check the clear width with the door fully open.',
      standard: 'Door clear width: minimum 32 inches / 815 mm.',
    ),
    'doorway|threshold': _Guidance(
      explanation: 'A raised threshold can stop small front casters, walkers, and mobility aids at the entry point.',
      fix: 'Replace the raised threshold with a flush transition. If a small level change must remain, bevel it and keep it below 13 mm.',
      standard: 'Accessible thresholds should be flush or no more than about 13 mm when beveled.',
    ),
    'elevator|braille labels': _Guidance(
      explanation: 'Without tactile or braille labels, blind and low-vision users may not be able to identify elevator controls independently.',
      fix: 'Add braille and raised tactile labels beside each control button. Keep labels consistently placed and ensure emergency controls are also identifiable by touch.',
      standard: 'Elevator controls should include tactile/braille identification and reachable button placement.',
    ),
    'parking|space width': _Guidance(
      explanation: 'The accessible parking bay appears too narrow. Wheelchair users need side clearance to transfer from a vehicle and deploy mobility equipment.',
      fix: 'Mark an accessible parking bay with an access aisle. Use a total width of about 3.6 m or provide a standard bay plus a clearly marked side transfer aisle.',
      standard: 'Accessible parking should provide a widened bay and transfer aisle; 3.6 m total width is a practical target.',
    ),
    'parking|path to entrance': _Guidance(
      explanation: 'An accessible parking space is not useful if there is no continuous route from the bay to the entrance.',
      fix: 'Create a marked, step-free route from the parking bay to the building entrance. Keep it firm, slip-resistant, well lit, and protected from vehicle movement.',
      standard: 'Accessible routes should be continuous, step-free, firm, stable, and slip-resistant.',
    ),
    'staircase|alternative route': _Guidance(
      explanation: 'A staircase without a nearby ramp or elevator creates a complete access barrier for wheelchair users and many people with mobility limitations.',
      fix: 'Provide a nearby ramp, platform lift, or elevator as the primary accessible route. Add clear signage at the staircase pointing users to that route.',
      standard: 'Public access routes should include a step-free alternative wherever stairs are present.',
    ),
    'staircase|handrails': _Guidance(
      explanation: 'Handrails on only one side reduce support for users who rely on a stronger side, cane, or assisted movement.',
      fix: 'Install continuous handrails on both sides of the stair flight. Ensure the rail is easy to grip and continues through landings where possible.',
      standard: 'Stairs should have continuous handrails on both sides.',
    ),
    'staircase|tactile warning': _Guidance(
      explanation: 'Missing tactile warning strips make stair edges harder to detect for blind and low-vision users.',
      fix: 'Install tactile warning tiles at the top and bottom of the staircase, placed before the first step so users receive warning before entering the hazard zone.',
      standard: 'Tactile warning indicators should be used before level changes and stair hazards.',
    ),
    'road / pathway|curb cuts': _Guidance(
      explanation: 'Without curb cuts, a sidewalk or road crossing becomes discontinuous for wheelchair users, stroller users, and people using walkers.',
      fix: 'Add curb ramps at crossings and intersections. Keep the ramp aligned with the crossing path and ensure the surface is non-slip.',
      standard: 'Pedestrian routes should remain step-free at crossings through curb ramps or level transitions.',
    ),
    'road / pathway|tactile paving': _Guidance(
      explanation: 'Missing tactile paving reduces independent navigation for blind and low-vision pedestrians.',
      fix: 'Add tactile guiding strips along the safe walking path and warning tiles before crossings, hazards, and level changes.',
      standard: 'Tactile ground surface indicators should guide routes and warn before hazards.',
    ),
    'home / residential|entrance access': _Guidance(
      explanation: 'The entrance may not provide step-free access, which can make the home difficult to enter without assistance.',
      fix: 'Create a step-free entry using a permanent ramp, portable threshold ramp, or level landing. Keep the entry route clear and slip-resistant.',
      standard: 'Accessible homes should provide at least one step-free entrance route.',
    ),
    'home / residential|door width': _Guidance(
      explanation: 'Residential doors are often too narrow for wheelchair users, especially at bathrooms, bedrooms, and main entrances.',
      fix: 'Widen the clear door opening to at least 815 mm where possible. Use offset hinges as a lower-cost improvement when full widening is not immediately possible.',
      standard: 'Door clear width: minimum 32 inches / 815 mm.',
    ),
    'hospital / medical|signage': _Guidance(
      explanation: 'Weak signage in medical spaces delays patients and caregivers, especially during stress or emergencies.',
      fix: 'Add high-contrast directional signage with wheelchair symbols, arrows, and simple wording. Place signs at seated and standing eye levels.',
      standard: 'Public healthcare signage should be clear, high contrast, and consistently placed along accessible routes.',
    ),
    'hospital / medical|emergency access': _Guidance(
      explanation: 'If emergency routes are not wheelchair accessible, people with mobility disabilities may be trapped during evacuation.',
      fix: 'Audit every emergency route for step-free movement, door clearance, refuge areas, and signage. Mark accessible evacuation paths clearly.',
      standard: 'Emergency egress plans should include accessible evacuation routes and refuge planning.',
    ),
    'commercial / mall|floor navigation': _Guidance(
      explanation: 'Narrow aisles make it difficult for wheelchair users to move, turn, or pass other shoppers independently.',
      fix: 'Keep main aisles at least 900 mm clear, remove temporary displays from circulation paths, and keep turning areas open near counters and entrances.',
      standard: 'Accessible routes should maintain at least 900 mm clear width, with wider turning spaces where needed.',
    ),
    'commercial / mall|elevator availability': _Guidance(
      explanation: 'If all public floors are not connected by elevator, the site becomes partially inaccessible even if the entrance is accessible.',
      fix: 'Provide elevator access to every public floor or clearly route users to an accessible lift. Add signs at stairs and entrances.',
      standard: 'Multi-floor public facilities should provide an accessible vertical circulation route.',
    ),
    'transit / bus stop|platform level': _Guidance(
      explanation: 'A platform height mismatch makes boarding difficult or impossible without driver assistance or a deployable ramp.',
      fix: 'Provide level boarding where possible. If that is not feasible, ensure deployable ramps work reliably and keep the boarding zone clear.',
      standard: 'Transit boarding should support step-free entry through level boarding or ramp access.',
    ),
    'transit / bus stop|waiting area': _Guidance(
      explanation: 'A waiting area without wheelchair space forces users into circulation paths or unsafe roadside positions.',
      fix: 'Reserve a clear wheelchair space beside seating under the shelter. Keep the space connected to the accessible approach path.',
      standard: 'Waiting areas should include clear floor space for wheelchair users beside fixed seating.',
    ),
    'transit / bus stop|information display': _Guidance(
      explanation: 'Information placed too high or too small can be unreadable for seated users and low-vision passengers.',
      fix: 'Place route information around 1.2 m height where possible, use high contrast text, and keep critical information readable from a seated position.',
      standard: 'Passenger information should be readable from seated and standing positions.',
    ),
    'garden / outdoor|path surface': _Guidance(
      explanation: 'Loose or uneven outdoor surfaces increase rolling resistance and can trap wheelchair wheels or walking aids.',
      fix: 'Use firm, stable, slip-resistant paving or compacted material on the main accessible route. Repair loose gravel, mud patches, and uneven joints.',
      standard: 'Accessible outdoor paths should be firm, stable, and slip-resistant.',
    ),
    'garden / outdoor|slope & terrain': _Guidance(
      explanation: 'Steep or uneven terrain can make outdoor movement unsafe and tiring for wheelchair users and older adults.',
      fix: 'Route the accessible path along the gentlest terrain. Keep running slopes around 1:20 where possible, and add landings/rest points on longer routes.',
      standard: 'Outdoor accessible paths should use gentle gradients, commonly 1:20 where feasible.',
    ),
    'office / building|entry door': _Guidance(
      explanation: 'A heavy or difficult entry door can block independent access even when the doorway itself is wide enough.',
      fix: 'Install an automatic opener, push-button assist, or low-force door closer. Ensure the activation button is reachable from a seated position.',
      standard: 'Accessible entrances should support independent opening with low force or automatic operation.',
    ),
    'office / building|reception height': _Guidance(
      explanation: 'A high reception counter prevents wheelchair users from completing check-in, payment, or conversation comfortably.',
      fix: 'Add a lowered service section around 760 mm high with knee clearance, or provide an adjacent accessible writing/check-in surface.',
      standard: 'Accessible service counters should include a lowered section around 760 mm high.',
    ),
    'any|clear pathway': _Guidance(
      explanation: 'The route may not have enough clear width for wheelchair movement, turning, or safe passing.',
      fix: 'Keep at least 900 mm of clear width on the route. Remove movable objects, signboards, parked two-wheelers, furniture, or debris from the path.',
      standard: 'Accessible routes should maintain at least 900 mm clear passage width.',
    ),
    'any|level access': _Guidance(
      explanation: 'A step or sudden level change can stop wheelchair users and create a trip hazard for many pedestrians.',
      fix: 'Provide a ramp or level transition for the height change. For very small changes, use a beveled threshold and keep the transition visible.',
      standard: 'Level changes on accessible routes should be ramped, beveled, or removed.',
    ),
  };
}

class _Guidance {
  final String explanation;
  final String fix;
  final String standard;

  const _Guidance({
    required this.explanation,
    required this.fix,
    required this.standard,
  });
}
