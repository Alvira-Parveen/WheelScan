import 'package:flutter/material.dart';
import '../config/theme.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
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
                  child: Icon(Icons.tune, size: 20, color: WheelScanTheme.textSecondary),
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
                _buildFilterChip('All', true),
                _buildFilterChip('Ramps', false),
                _buildFilterChip('Doorways', false),
                _buildFilterChip('Elevators', false),
                _buildFilterChip('Parking', false),
                _buildFilterChip('Roads', false),
                _buildFilterChip('Other', false),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Feed List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFeedCard(
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
                _buildFeedCard(
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
                _buildFeedCard(
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
                _buildFeedCard(
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
                _buildFeedCard(
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
                _buildFeedCard(
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: WheelScanTheme.textPrimary,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
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
                  Icon(Icons.location_on, size: 16, color: WheelScanTheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
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
                      style: TextStyle(
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
              style: TextStyle(
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
                Icon(Icons.bookmark_outline, size: 20, color: WheelScanTheme.textSecondary),
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
}