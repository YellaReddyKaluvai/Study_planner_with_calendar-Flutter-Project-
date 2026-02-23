# 📚 Study Planner Ultra - Next Level Edition

A **premium Flutter study planner** with **real-time analytics**, **focus timer**, **streak tracking**, and **AI-powered insights** to help students master their exams and optimize study habits.

## ✨ Key Features

### 🎯 Core Features
- ✅ **Smart Task Management** - Create, track, and prioritize study tasks
- ✅ **Interactive Calendar** - Visual schedule with task overlays
- ✅ **AI Chatbot** - Get personalized study recommendations powered by Gemini AI
- ✅ **Gamification** - Earn XP, badges, and achievements
- ✅ **Multi-platform** - Works on Android, iOS, Web, Windows, Linux, macOS

### 🆕 **Next Level+ Features** (Just Added!)

#### 📊 **Real-Time Analytics Dashboard**
- Visual bar charts showing weekly study progress
- Subject performance breakdown
- Productivity scoring (0-100%)
- Lifetime study statistics
- Average session duration tracking

#### ⏱️ **Professional Focus Timer**
- 🍅 Pomodoro preset (25 minutes)
- 🧠 Deep Work mode (50 minutes)
- ⚡ Quick Focus sessions (5 minutes)
- 💪 Marathon mode (90 minutes)
- Custom duration support
- Real-time progress tracking
- **Auto-saves sessions to analytics**

#### 🔥 **Study Streak System**
- Track consecutive days of studying
- Earn badges at milestones (7, 30, 100, 365 days)
- Streak freezes (skip one missed day penalty-free)
- Current & longest streak display
- Daily motivation notifications

#### 📈 **Advanced Analytics**
- Weekly/monthly trend analysis
- Subject performance insights
- Focus quality tracking
- Session metadata (time, tasks completed, notes)
- Productivity insights for optimization

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0+ ([Install here](https://flutter.dev/docs/get-started/install))
- Firebase account (for authentication & cloud sync)
- Gemini API key (for AI chatbot)

### Installation

```bash
# Clone the repository  
git clone https://github.com/yourusername/study_planner_with_calendar.git
cd study_planner_with_calendar

# Install dependencies
flutter pub get

# Generate build files
flutter pub run build_runner build

# Run the app
flutter run
```

### Configuration

1. **Firebase Setup** - Update `firebase_options.dart` with your Firebase config
2. **Gemini API** - Add your API key in the app settings (first launch)
3. **Notification Permissions** - Grant permissions when prompted

---

## 📖 Documentation

- **[Quick Start Guide](./QUICK_START.md)** - Get started in 2 minutes
- **[Complete Enhancements](./ENHANCEMENTS.md)** - Detailed feature documentation
- **[Architecture & Technical Guide](./ARCHITECTURE.md)** - For developers

---

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── theme/                         # App theme & colors
│   └── services/                      # Firebase & core services
├── models/                            # Data models
│   ├── study_session.dart            # Enhanced session tracking
│   ├── study_task.dart               # Task model
│   └── ...
├── services/                          # Business logic
│   ├── analytics_service.dart         # 📊 NEW: Track metrics
│   ├── streak_service.dart            # 🔥 NEW: Streak tracking
│   ├── focus_timer_service.dart       # ⏱️ NEW: Timer management
│   ├── local_db_service.dart         # SQLite persistence
│   ├── firestore_service.dart        # Cloud sync
│   └── ...
├── presentation/
│   ├── providers/                     # State management
│   │   ├── analytics_provider.dart    # 📊 NEW: Analytics state
│   │   ├── task_provider.dart         # Task state
│   │   └── ...
│   ├── features/
│   │   ├── home/                      # Dashboard
│   │   ├── focus/                     # ⏱️ NEW: Timer UI
│   │   ├── analytics/                 # 📊 NEW: Analytics UI
│   │   ├── tasks/                     # Task management
│   │   ├── calendar/                  # Calendar view
│   │   ├── gamification/              # Games & achievements
│   │   ├── chatbot/                   # AI chat
│   │   └── ...
│   └── shared/                        # Reusable widgets
└── ...
```

---

## 🎮 How to Use

### Starting a Study Session
1. Click the **⏱️ Timer** button on the dashboard
2. Select a preset (Pomodoro, Deep Work, etc.)
3. Click **Play** to start
4. Timer automatically saves when complete

### Checking Your Progress
1. Dashboard shows **Weekly Chart** with daily study time
2. See **productivity score** compared to target
3. Check **current streak** and next badge milestone

### Understanding Streaks
- Study any amount each day → +1 to streak
- Miss a day → streak resets (but **Freeze** prevents this!)
- Reach milestones for badges and XP bonuses

---

## 📱 Screenshots & Features

### Before
- ❌ "Charts initialized..." placeholder
- ❌ No timer system
- ❌ No analytics
- ❌ Limited gamification

### After (Next Level+)
- ✅ Real bar charts with weekly data
- ✅ Professional focus timer with presets
- ✅ Complete analytics dashboard
- ✅ Advanced streak & badge system
- ✅ Productivity scoring

---

## 🔧 Technology Stack

### Frontend
- **Flutter 3.0+** - Cross-platform UI framework
- **Provider** - State management
- **get_it** - Service locator
- **google_fonts** - Custom typography
- **flutter_animate** - Smooth animations
- **fl_chart** - Beautiful data visualization

### Backend & Database
- **Firebase** - Authentication, Firestore, Cloud Messaging
- **SQLite (sqflite)** - Offline local database
- **SharedPreferences** - Lightweight data storage
- **Google Generative AI (Gemini)** - AI chatbot

### Development
- **Dart** - Programming language
- **build_runner** - Code generation
- **linter** - Code analysis

---

## 🎯 Use Cases

### For Students
- 📚 Organize exam preparation with smart scheduling
- 🔥 Maintain study consistency with streak tracking  
- 📊 Visualize progress with real-time analytics
- ⏱️ Optimize focus sessions with scientific timer
- 🤖 Get AI recommendations for improvement

### For Teachers
- 📈 Monitor classroom study patterns
- 🏆 Motivate students with achievement system
- 📊 Access analytics for class performance insights

### For Parents
- 👁️ Monitor child's study habits
- 🔥 See consistency via streak tracking
- ⏱️ Ensure focused study time with timer
- 📊 Review progress reports

---

## 🐛 Troubleshooting

### Firebase Issues
```bash
# Regenerate Firebase options
flutterfire configure
```

### Build Errors  
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Analytics Not Showing
- Start a focus timer session first
- Check AnalyticsProvider initialized (see main.dart)
- Manually refresh: pull down on dashboard

---

## 🚀 Deployment

### Android
```bash
flutter build apk --release
# Or: flutter build appbundle --release (for Play Store)
```

### iOS
```bash
flutter build ios --release
# Use Xcode to upload to App Store
```

### Web
```bash
flutter build web --release
# Deploy to Netlify, Firebase Hosting, etc.
```

---

## 🎓 Learning & Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package Guide](https://pub.dev/packages/provider)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Flutter & Dart teams for the amazing framework
- Firebase for comprehensive backend services
- Google Generative AI for ChatBot capabilities
- All contributors and users for feedback

---

## 📧 Support

- 💬 **Issues & Bugs** - Report via GitHub Issues
- 🌟 **Feature Requests** - Discuss in Discussions tab
- 📧 **Contact** - Email: support@studyplanner.dev

---

## 🔮 Future Roadmap

- [ ] **AI Smart Scheduling** - Auto-schedule study sessions
- [ ] **Social Features** - Study groups, leaderboards
- [ ] **Advanced Reports** - PDF export, statistics
- [ ] **Voice Commands** - Hands-free timer control  
- [ ] **Dark Mode Optimization** - OLED friendly theme
- [ ] **Desktop App** - Electron wrapper
- [ ] **API** - Public API for integrations

---

**Made with ❤️ for students who want to study smarter, not harder.**

**Ready to take your study game to the next level? [Get Started Now! →](./QUICK_START.md)** 🚀
