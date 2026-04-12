# 🚀 WheelScan - AI-Powered Accessibility Auditor for Public Spaces**

WheelScan is a Flutter mobile app that lets anyone scan public spaces (ramps, doorways, elevators, parking lots, staircases, roads, and more) and get instant accessibility scores with detailed breakdowns and recommendations.

Built as a semester project for **Flutter for Android Application Development** — B.Tech CSE (AI/ML), 4th Semester, Sharda University.

---

## 🎯 Problem Solved

WheelScan solves a real-world accessibility gap:

No easy way to check accessibility before visiting a place
Manual audits are expensive & rare
Users often face unexpected barriers

👉 WheelScan makes accessibility instant, scalable, and community-driven 

-- 

## 📌 What It Does/Key Features

- **📸 Scan Any Space** — Take a photo or upload from gallery
- **🧠 Smart Analysis** — Select from 5 preset categories or describe the space in your own words (supports 12+ space types)
- **📊 Detailed Scoring** — Get a score out of 100 with PASS / WARNING / CRITICAL breakdown for each criterion
- **🗺️ Accessibility Map** — View all audited locations on an interactive map with color-coded pins
- **👥 Community Feed** — See audits from other users with likes, comments, and shares
- **🏆 Profile and Badges** — Track your audits, earn badges, maintain streaks, and customize settings

---

## ✨ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter 3.38 | Cross-platform UI framework |
| Dart 3.10 | Programming language |
| image_picker | Camera and gallery access |
| CustomPainter | Score ring animation and map |
| AnimationController | Splash, score, and card animations |
| Material Design 3 | UI components and theming |

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point and navigation
├── config/
│   └── theme.dart               # Colors, gradients, text styles
├── models/
│   └── audit_model.dart         # AuditResult and AuditIssue classes
├── screens/
│   ├── splash_screen.dart       # Animated intro screen
│   ├── home_screen.dart         # Dashboard with stats and quick scan
│   ├── scan_screen.dart         # Image capture and space type selector
│   ├── result_screen.dart       # Animated score ring and breakdown
│   ├── map_screen.dart          # Interactive accessibility map
│   ├── feed_screen.dart         # Community audit feed
│   └── profile_screen.dart      # User profile, badges, settings
├── services/
│   └── scoring_service.dart     # AI scoring engine (12+ categories)
└── widgets/
    └── score_gauge.dart         # Reusable score display widget
```

---

## ⭐ AI Scoring Engine

WheelScan uses a keyword-based scoring engine that supports 12+ space categories:

**Preset Categories:** Ramp, Doorway, Elevator, Parking, Staircase

**Custom Categories (via text input):** Road/Pathway, Home/Residential, Hospital/Medical, Mall/Commercial, Transit/Bus Stop, Garden/Outdoor, Office/Building, and a generic fallback

Each category has specific accessibility criteria. Every criterion is rated:
- **GOOD** = 30 points (meets accessibility standards)
- **WARNING** = 15 points (needs improvement)
- **CRITICAL** = 0 points (fails standards)

**Score Formula:** (Total Points Earned / Maximum Possible Points) x 100

---

## 🧠 How to Run

1. Make sure Flutter is installed (run flutter doctor)
2. Clone this repository
3. Navigate to the project folder
4. Run flutter pub get to install dependencies
5. Run flutter run to start the app

---

##  📊 Flutter Concepts Used

StatefulWidget and StatelessWidget, setState for reactive UI, Navigator push and pop, async/await, CustomPainter for canvas drawing, AnimationController with CurvedAnimation, BottomSheet and AlertDialog, GestureDetector, SingleChildScrollView, ListView.builder, and image_picker package.

---

## 🔮 Future Scope

- Real AI Model — Train MobileNetV2 with TFLite for actual image classification
- Firebase Backend — Authentication, Firestore database, cloud storage
- Google Maps SDK — Real map with GPS locations
- PDF Report Export — Professional audit reports
- Voice Input — Describe spaces using speech-to-text
- Multi-Language — Hindi, Spanish, French, Arabic support

---

## 👤 Author

**Name**: ALVIRA PARVEEN  
🔗 [LinkedIn](https://www.linkedin.com/in/alvira-parveen-78022536b)  
🌐 [GitHub](https://github.com/Alvira-Parveen)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

