import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedCategory = 'All';

  final Map<String, String> _aiInsights = {
    'All': 'Across 14 audits in this region, missing tactile warnings (43%) and narrow doorway clearances (28%) represent the most common critical barriers. Recommended: Flag DLF Cyberhub & CP Metro Station barriers to Delhi Metro (DMRC) & municipal authorities.',
    'Ramps': 'Across 5 ramp audits, slope angles steeper than 1:12 (60%) remain the most prominent barrier. Dual continuous handrails are generally present in most public spots.',
    'Doorways': 'Across 4 doorway audits, doors narrower than 815mm are the leading cause of critical accessibility failure (75%). Remediate by installing auto-assist openers.',
    'Elevators': 'Across 3 elevator audits, missing Braille indicators on control buttons is the only critical barrier reported. A low-cost DIY fix with Braille stickers is recommended.',
    'Parking': 'Across 4 parking audits, narrow access aisles (<3.6m) and lack of a step-free path to entrance are critical barriers in 50% of spaces. Repaint access markings.',
    'Roads': 'Across 6 pedestrian road audits, missing tactile paving (83%) and absent curb ramps at crossings are marked as critical barriers. Flagging to civic authorities recommended.',
    'Other': 'Across 2 custom audited residential spaces, uneven entrance gate thresholds were identified as the main barrier. Ensure beveled or flush transitions.',
  };

  void _copyInsightText() {
    final insight = _aiInsights[_selectedCategory] ?? '';
    Clipboard.setData(ClipboardData(text: 'WheelScan AI Insight ($_selectedCategory): $insight'));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('AI Community Insight copied to clipboard'),
        backgroundColor: WheelScanTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate filtered feed cards based on category
    final feedItems = _getFilteredFeedItems();

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Community Feed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: WheelScanTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune, size: 20, color: WheelScanTheme.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Filter Chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Ramps'),
                _buildFilterChip('Doorways'),
                _buildFilterChip('Elevators'),
                _buildFilterChip('Parking'),
                _buildFilterChip('Roads'),
                _buildFilterChip('Other'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Dynamic AI Insights Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    WheelScanTheme.darkSurface,
                    WheelScanTheme.darkCard,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: WheelScanTheme.darkSurface.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: WheelScanTheme.primary, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Community Insights',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _copyInsightText,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.copy_rounded, color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _aiInsights[_selectedCategory] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Feed List
          Expanded(
            child: feedItems.isEmpty
                ? Center(
                    child: Text(
                      'No audits found in this category.',
                      style: TextStyle(color: WheelScanTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: feedItems.length,
                    itemBuilder: (context, index) {
                      final item = feedItems[index];
                      return _buildFeedCard(
                        userName: item.userName,
                        userInitial: item.userInitial,
                        avatarColor: item.avatarColor,
                        location: item.location,
                        spaceType: item.spaceType,
                        score: item.score,
                        timeAgo: item.timeAgo,
                        likes: item.likes,
                        comments: item.comments,
                        description: item.description,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? WheelScanTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? WheelScanTheme.primary : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: WheelScanTheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : WheelScanTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedCard({
    required String userName,
    required String userInitial,
    required Color avatarColor,
    required String location,
    required String spaceType,
    required int score,
    required String timeAgo,
    required int likes,
    required int comments,
    required String description,
  }) {
    Color scoreColor;
    if (score >= 75) {
      scoreColor = WheelScanTheme.primary;
    } else if (score >= 50) {
      scoreColor = WheelScanTheme.warning;
    } else {
      scoreColor = WheelScanTheme.danger;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: avatarColor,
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: WheelScanTheme.textPrimary,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: WheelScanTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scoreColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 10,
                          color: scoreColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Location & Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: WheelScanTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: WheelScanTheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: WheelScanTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: WheelScanTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      spaceType,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: WheelScanTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: WheelScanTheme.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 14),

            // Actions Row
            Row(
              children: [
                _buildActionButton(Icons.thumb_up_outlined, '$likes', WheelScanTheme.textSecondary),
                const SizedBox(width: 20),
                _buildActionButton(Icons.chat_bubble_outline, '$comments', WheelScanTheme.textSecondary),
                const SizedBox(width: 20),
                _buildActionButton(Icons.share_outlined, 'Share', WheelScanTheme.textSecondary),
                const Spacer(),
                const Icon(Icons.bookmark_outline, size: 20, color: WheelScanTheme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<_FeedItem> _getFilteredFeedItems() {
    final allItems = [
      _FeedItem(
        userName: 'Rahul Sharma',
        userInitial: 'R',
        avatarColor: Colors.blue,
        location: 'AIIMS Hospital Main Entrance',
        spaceType: 'Doorway',
        score: 91,
        timeAgo: '15 min ago',
        likes: 12,
        comments: 3,
        description: 'Excellent accessibility! Automatic sliding doors, wide entrance, and proper signage. One of the best hospital entrances I\'ve audited.',
      ),
      _FeedItem(
        userName: 'Priya Singh',
        userInitial: 'P',
        avatarColor: Colors.purple,
        location: 'Connaught Place Metro Station',
        spaceType: 'Elevator',
        score: 78,
        timeAgo: '1 hr ago',
        likes: 8,
        comments: 5,
        description: 'Elevator works well but braille labels are missing on buttons. Reported to DMRC for improvement.',
      ),
      _FeedItem(
        userName: 'Alvira Parveen',
        userInitial: 'A',
        avatarColor: WheelScanTheme.primary,
        location: 'Sharda University Main Library',
        spaceType: 'Ramp',
        score: 85,
        timeAgo: '2 hrs ago',
        likes: 15,
        comments: 7,
        description: 'Library ramp has handrails on both sides and non-slip surface. Slope is slightly steep but manageable. Good job Sharda!',
      ),
      _FeedItem(
        userName: 'Amit Kumar',
        userInitial: 'A',
        avatarColor: Colors.orange,
        location: 'Select City Walk Mall',
        spaceType: 'Parking',
        score: 45,
        timeAgo: '3 hrs ago',
        likes: 22,
        comments: 11,
        description: 'Accessible parking spaces are there but poorly maintained. No clear path from parking to mall entrance. Needs serious attention.',
      ),
      _FeedItem(
        userName: 'Sneha Gupta',
        userInitial: 'S',
        avatarColor: Colors.teal,
        location: 'Sector 18 Market Road',
        spaceType: 'Road / Pathway',
        score: 60,
        timeAgo: '5 hrs ago',
        likes: 6,
        comments: 2,
        description: 'Road surface is okay but no curb cuts at crossings. Tactile paving completely absent. Wheelchair users would struggle at intersections.',
      ),
      _FeedItem(
        userName: 'Tanisha Verma',
        userInitial: 'T',
        avatarColor: Colors.pink,
        location: 'DLF Cyberhub Office Lobby',
        spaceType: 'Office / Building',
        score: 88,
        timeAgo: '8 hrs ago',
        likes: 19,
        comments: 4,
        description: 'Very well designed lobby. Automatic doors, wide corridors, lowered reception counter, and accessible elevator right at entrance.',
      ),
    ];

    if (_selectedCategory == 'All') {
      return allItems;
    }

    String matchType;
    switch (_selectedCategory) {
      case 'Ramps':
        matchType = 'Ramp';
        break;
      case 'Doorways':
        matchType = 'Doorway';
        break;
      case 'Elevators':
        matchType = 'Elevator';
        break;
      case 'Parking':
        matchType = 'Parking';
        break;
      case 'Roads':
        matchType = 'Road / Pathway';
        break;
      default:
        matchType = 'Office / Building';
    }

    return allItems.where((item) => item.spaceType == matchType).toList();
  }
}

class _FeedItem {
  final String userName;
  final String userInitial;
  final Color avatarColor;
  final String location;
  final String spaceType;
  final int score;
  final String timeAgo;
  final int likes;
  final int comments;
  final String description;

  _FeedItem({
    required this.userName,
    required this.userInitial,
    required this.avatarColor,
    required this.location,
    required this.spaceType,
    required this.score,
    required this.timeAgo,
    required this.likes,
    required this.comments,
    required this.description,
  });
}