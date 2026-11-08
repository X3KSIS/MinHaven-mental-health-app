# 🧠 MindHaven – Mental Health & Wellness App

MindHaven is a cross-platform mobile app built with **Flutter** and **Firebase** that helps users look after their mental wellbeing. It combines an AI-powered support chatbot, mood tracking with AI-generated insights, journaling, gamified daily challenges, and quick access to crisis helplines and mental health centres in Zambia.

> 🎓 Developed as a **Final Year Project**.

---

## 📸 Screenshots

| Login | Home | AI Chatbot |
|:---:|:---:|:---:|
| <img src="screenshots/login.png" width="230"/> | <img src="screenshots/home.png" width="230"/> | <img src="screenshots/chatbot.png" width="230"/> |

| Mood Dashboard | Journal | Achievements |
|:---:|:---:|:---:|
| <img src="screenshots/mood_dashboard.png" width="230"/> | <img src="screenshots/journal.png" width="230"/> | <img src="screenshots/achievements.png" width="230"/> |

| Crisis Helplines | Profile | Settings |
|:---:|:---:|:---:|
| <img src="screenshots/crisis_helplines.png" width="230"/> | <img src="screenshots/profile.png" width="230"/> | <img src="screenshots/settings.png" width="230"/> |

---

## ✨ Features

### 🔐 Authentication
- Register and log in with email and password (Firebase Authentication)
- Password reset via email
- Persistent sessions managed with the BLoC/Cubit pattern

### 🤖 AI Support Chatbot
- Conversational support powered by **Google Gemini (gemini-2.5-flash)**
- Multiple saved chat sessions stored in Cloud Firestore
- **Content moderation**: profanity filtering plus crisis detection. If a message suggests the user is at risk, the bot responds with Zambian crisis helpline numbers instead of a normal reply
- Gemini safety settings enabled for harassment, hate speech, sexual and dangerous content

### 📊 Mood Tracker
- Log daily moods with a score and an optional note
- Interactive mood charts (built with `fl_chart`)
- Mood statistics cards and a recent-moods history
- **AI insights**: sentiment analysis of recent entries gives personalised daily insights
- **Weekly reports**: AI-generated summaries of your emotional patterns across the week

### 📓 Journal
- Write, edit and delete private journal entries
- Tag entries with a mood (😊 Happy, 😔 Sad, 😰 Anxious, 😌 Calm, 😤 Frustrated, 💪 Motivated, 😴 Tired, 🤔 Reflective)
- Search and filter your entries

### 🏆 Gamification
- Earn **points** for healthy actions such as logging moods, journaling and chatting
- **Streaks** for consistent daily check-ins
- **Daily challenges** such as *Morning Mood Check*, *Evening Reflection*, *Chat Session* and *Gratitude Practice*
- Unlockable **achievements/badges**, e.g. *First Steps*, *Mood Warrior*, *Pen to Paper*, *Consistency Champion*, *Deep Thinker*

### 🆘 Resources & Crisis Support
- **Crisis Helplines**: one tap to reach emergency support lines
- **Mental Health Centres**: professional help available in Zambia
- **Self-Care Tips**: daily practices for mental wellness

### 👤 Profile & ⚙️ Settings
- Profile picture upload from camera or gallery (Firebase Storage)
- Account statistics overview
- Light and dark mode
- Notification and daily-reminder preferences
- Clear personal data or permanently delete your account

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | `flutter_bloc` (Cubit) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| File storage | Firebase Storage |
| AI | Google Gemini via `google_generative_ai` |
| Charts | `fl_chart` |
| Moderation | `profanity_filter` + custom crisis detection |
| UI | `google_nav_bar`, `font_awesome_flutter`, `loading_animation_widget` |
| Testing | `flutter_test`, `mocktail`, `bloc_test` |

### 🎨 Theme
Calm greyscale light and dark themes with meaningful accent colours, using the **Poppins** and **Courgette** fonts. See **[docs/THEME.md](docs/THEME.md)** for the full colour palette, typography and design guidelines.

---

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.example.dart   # Template, generate your own (see Setup)
├── themes/                         # Light & dark themes
├── widgets/                        # Shared widgets
└── features/
    ├── auth/                       # Login, register, Firebase auth repo, cubits
    ├── Home/                       # Home screen, quick actions, resource sheets
    ├── chatbot/                    # Gemini chatbot + moderation
    ├── mood_tracker/               # Mood logging, charts, AI insights, weekly reports
    ├── journal/                    # Journal entries, search & filter
    ├── gamification/               # Points, streaks, challenges, achievements
    ├── profile/                    # User profile & stats
    └── settings/                   # App preferences & account management
datasets/
└── Combined Data.csv               # Labelled mental-health statements (e.g. Anxiety) used for research
test/
├── login_test.dart
└── register_test.dart
```

The app follows a **feature-first clean architecture**. Each feature is split into `data` (models, services, repositories), `domain` (entities, abstract repos) and `presentation` (pages, components, cubits) layers.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or VS Code with the Flutter plugin
- A [Firebase](https://console.firebase.google.com/) project
- A [Google Gemini API key](https://aistudio.google.com/app/apikey)

> ⚠️ API keys and Firebase config files are **not** included in this repository. You need to provide your own.

### 1. Clone the repository
```bash
git clone https://github.com/X3KSIS/MinHaven-mental-health-app.git
cd MinHaven-mental-health-app
flutter pub get
```

### 2. Configure Firebase
1. Create a Firebase project and enable **Email/Password Authentication**, **Cloud Firestore** and **Storage**.
2. Install the FlutterFire CLI and connect the app:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and `android/app/google-services.json`. See `lib/firebase_options.example.dart` for the expected format.

### 3. Add your Gemini API key
The key is passed in at build time and never stored in the code:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```
**Android Studio:** Run → Edit Configurations → *Additional run args* → `--dart-define=GEMINI_API_KEY=your_key_here`

### 4. Run the tests
```bash
flutter test
```

---

## ⚠️ Disclaimer

MindHaven is a student project and is **not a substitute for professional medical advice, diagnosis or treatment**. If you or someone you know is in crisis, contact a local emergency service or a crisis helpline immediately.

---

## 👤 Author

**X3KSIS**, Final Year Project
GitHub: [@X3KSIS](https://github.com/X3KSIS)
