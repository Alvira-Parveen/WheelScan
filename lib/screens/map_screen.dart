import 'package:flutter/material.dart';
import '../config/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedFilter = 'All';
  int? _selectedLocationIndex;

  final List<Map<String, dynamic>> _locations = [
    {
      'name': 'Main Library Entrance',
      'type': 'Ramp',
      'score': 85,
      'address': 'Sharda University, Block A',
      'time': '2 hrs ago',
      'top': 0.18,
      'left': 0.35,
    },
    {
      'name': 'Cafeteria Parking',
      'type': 'Parking',
      'score': 62,
      'address': 'Sharda University, Food Court',
      'time': '5 hrs ago',
      'top': 0.35,
      'left': 0.65,
    },
    {
      'name': 'Admin Block Stairs',
      'type': 'Staircase',
      'score': 34,
      'address': 'Sharda University, Admin Wing',
      'time': 'Yesterday',
      'top': 0.52,
      'left': 0.25,
    },
    {
      'name': 'Science Block Elevator',
      'type': 'Elevator',
      'score': 89,
      'address': 'Sharda University, Block C',
      'time': 'Yesterday',
      'top': 0.28,
      'left': 0.78,
    },
    {
      'name': 'Gate 2 Entrance',
      'type': 'Doorway',
      'score': 71,
      'address': 'Sharda University, Gate 2',
      'time': '2 days ago',
      'top': 0.68,
      'left': 0.45,
    },
    {
      'name': 'Campus Road',
      'type': 'Road / Pathway',
      'score': 80,
      'address': 'Sharda University, Main Road',
      'time': '3 days ago',
      'top': 0.45,
      'left': 0.50,
    },
    {
      'name': 'Hostel Block Ramp',
      'type': 'Ramp',
      'score': 92,
      'address': 'Sharda University, Hostel Area',
      'time': '3 days ago',
      'top': 0.75,
      'left': 0.72,
    },
    {
      'name': 'Sports Complex Entry',
      'type': 'Doorway',
      'score': 55,
      'address': 'Sharda University, Sports Block',
      'time': '4 days ago',
      'top': 0.60,
      'left': 0.15,
    },
  ];

  Color _getScoreColor(int score) {
    if (score >= 75) return WheelScanTheme.primary;
    if (score >= 50) return WheelScanTheme.warning;
    return WheelScanTheme.danger;
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Ramp':
        return Icons.accessibility_new;
      case 'Doorway':
        return Icons.door_front_door;
      case 'Elevator':
        return Icons.elevator;
      case 'Parking':
        return Icons.local_parking;
      case 'Staircase':
        return Icons.stairs;
      case 'Road / Pathway':
        return Icons.route;
      default:
        return Icons.place;
    }
  }

  List<Map<String, dynamic>> get _filteredLocations {
    if (_selectedFilter == 'All') return _locations;
    return _locations.where((loc) => loc['type'] == _selectedFilter).toList();
  }

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
                  'Accessibility Map',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: WheelScanTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
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
                      child: Icon(Icons.my_location, size: 20, color: WheelScanTheme.primary),
                    ),
                  ],
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
                _buildFilterChip('Ramp'),
                _buildFilterChip('Doorway'),
                _buildFilterChip('Elevator'),
                _buildFilterChip('Parking'),
                _buildFilterChip('Staircase'),
                _buildFilterChip('Road / Pathway'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildLegendItem(WheelScanTheme.primary, 'Accessible (75+)'),
                const SizedBox(width: 16),
                _buildLegendItem(WheelScanTheme.warning, 'Partial (50-74)'),
                const SizedBox(width: 16),
                _buildLegendItem(WheelScanTheme.danger, 'Poor (<50)'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Map Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0E8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Grid lines to simulate map
                      CustomPaint(
                        size: Size.infinite,
                        painter: _MapGridPainter(),
                      ),

                      // Campus label
                      Positioned(
                        top: 8,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 14, color: WheelScanTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Sharda University Campus',
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

                      // Location Pins
                      ..._filteredLocations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final loc = entry.value;
                        final score = loc['score'] as int;
                        final color = _getScoreColor(score);
                        final isSelected = _selectedLocationIndex == index;

                        return Positioned(
                          top: (loc['top'] as double) * 300,
                          left: (loc['left'] as double) * 300,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLocationIndex = isSelected ? null : index;
                              });
                            },
                            child: Column(
                              children: [
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${loc['name']}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: WheelScanTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 40 : 32,
                                  height: isSelected ? 40 : 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: isSelected ? 10 : 6,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$score',
                                      style: TextStyle(
                                        fontSize: isSelected ? 12 : 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Stats overlay
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_filteredLocations.length} locations',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: WheelScanTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Location Cards List
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final loc = _filteredLocations[index];
                final score = loc['score'] as int;
                final color = _getScoreColor(score);
                final isSelected = _selectedLocationIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLocationIndex = isSelected ? null : index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: isSelected ? 12 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getTypeIcon(loc['type']),
                                size: 16,
                                color: color,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$score',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc['name'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WheelScanTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${loc['type']}  •  ${loc['time']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: WheelScanTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
            _selectedLocationIndex = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? WheelScanTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? WheelScanTheme.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : WheelScanTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: WheelScanTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.08)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw some "road" lines
    final roadPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.2), Offset(size.width * 0.7, size.height * 0.8), roadPaint);

    // Building blocks
    final blockPaint = Paint()
      ..color = Colors.green.withOpacity(0.06);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(20, 20, 80, 60), const Radius.circular(4)),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 120, 30, 90, 50), const Radius.circular(4)),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(30, size.height - 100, 100, 70), const Radius.circular(4)),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 140, size.height - 90, 110, 60), const Radius.circular(4)),
      blockPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}