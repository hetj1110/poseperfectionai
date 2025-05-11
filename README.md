# PosePerfectionAI 🧘‍♀️📱

**PosePerfectionAI** is a Flutter-powered fitness coaching app that uses real-time camera feedback to evaluate posture, count reps, and provide audio cues. It also visualizes session history with interactive charts.

---

## 🚀 Features

- 📸 Uses **front-facing camera** for posture monitoring  
- 🧠 Real-time **rep counting** and **posture scoring**  
- 🔊 Voice feedback via **Text-to-Speech (TTS)**  
- 📊 Historical performance visualization with **bar and line charts**  
- 💾 Local session storage using **SharedPreferences**  
- 🌓 Dark theme by default  

---

## 📂 Project Structure

\`\`\`
lib/
├── main.dart                # App entry point with routing
├── splash_screen.dart       # Splash/intro screen
├── dashboard.dart           # Home screen with charts and session logs
├── camera_screen.dart       # Core session logic with camera and TTS
├── session_history.dart     # Widget for visualizing history
├── models/
│   └── session_summary.dart # Model for session data
\`\`\`

---

## 🛠️ Setup Instructions

### 1. 📦 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio or Xcode for emulator/device testing
- A device with a **front-facing camera** (emulators may not work fully)
- Internet connection for TTS voice setup

### 2. 🧱 Install Dependencies

\`\`\`bash
flutter pub get
\`\`\`

### 3. 📱 Run the App

\`\`\`bash
flutter run
\`\`\`

- Make sure a real device or emulator is connected.
- Allow camera and microphone permissions when prompted.

---

## 📊 Libraries Used

| Package              | Purpose                        |
|----------------------|--------------------------------|
| \`camera\`             | Captures live video stream     |
| \`flutter_tts\`        | Provides voice feedback        |
| \`shared_preferences\` | Saves session data locally     |
| \`fl_chart\`           | Renders bar and line charts    |

---

## 🧪 Development Notes

- Data is persisted across sessions using \`SharedPreferences\`.
- When a session ends, it is saved locally and visualized on the Dashboard.
- A new session is started manually from the Dashboard via the "Play" button.

---

## 🧹 TODOs / Future Improvements

- Add unit tests and integration tests  
- Add export/share functionality for session history  
- Add authentication (Google/Apple)  
- Cloud sync or backup of user sessions  
- Real-time pose evaluation using ML models

---

## 📸 Screenshots

*Coming Soon*

---

## 👤 Author

Made by [Your Name or GitHub Handle]  
Feel free to contribute or fork this project!
