# MindHaven – Mental Health App

Final year school project: a Flutter mental wellness app with mood tracking, journaling, an AI chatbot (Google Gemini), gamification and crisis helpline resources. Backend is Firebase.

## Setup

Secrets are not included in this repository. To run the app you need your own keys.

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Firebase** – create a Firebase project, then run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and `android/app/google-services.json`.
   See `lib/firebase_options.example.dart` for the expected shape.

3. **Gemini API key** – get a key from [Google AI Studio](https://aistudio.google.com/app/apikey) and pass it at build time:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```
