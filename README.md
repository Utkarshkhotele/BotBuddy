# 🤖 BotBuddy – AI Chat Assistant

BotBuddy is a Flutter chat app with AI responses powered by the Gemini API.  
It features an animated onboarding screen (via Lottie), dark/light theming, chat history, and a sleek modern interface.

---

## 🚀 Demo
🌐 **Try it here:** [Live App](http://elaborate-hamster-77b81b.netlify.app)

---

## ✨ Features
- **Dark/Light Mode** toggle
- **Save Chat History** locally
- **Start New Chat** option
- **Clear Chat** button
- Animated onboarding screen
- Customizable app name and logo
- Gemini API-powered AI responses

---

## 📂 Setup

### 1️⃣ Clone the project
```bash
git clone https://github.com/Utkarshkhotele/BotBuddy.git
cd BotBuddy
2️⃣ Install dependencies
bash
Copy code
flutter pub get
3️⃣ Add your logo & Lottie animation
Place them in the assets/ directory:

bash
Copy code
assets/
 ├── logo.png         # Your app logo
 ├── chatbot.json     # Onboarding animation
Declare them in pubspec.yaml:

yaml
Copy code
flutter:
  assets:
    - assets/logo.png
    - assets/chatbot.json
4️⃣ Update App Name
Android → Edit android/app/src/main/res/values/strings.xml:

xml
Copy code
<string name="app_name">BotBuddy</string>
iOS → Edit ios/Runner/Info.plist:

xml
Copy code
<key>CFBundleName</key>
<string>BotBuddy</string>
5️⃣ (Optional) Set Launcher Icon
Add to pubspec.yaml:

yaml
Copy code
flutter_launcher_icons: ^0.10.0

flutter_icons:
  android: true
  ios: true
  image_path: "assets/logo.png"
Then run:

bash
Copy code
flutter pub run flutter_launcher_icons:main
6️⃣ Run the app
bash
Copy code
flutter run
🖼 Adding Your Logo in UI
In AppBar (e.g., in ChatScreen):

dart
Copy code
title: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Image.asset('assets/logo.png', width: 24, height: 24),
    const SizedBox(width: 8),
    const Text('BotBuddy', style: TextStyle(fontWeight: FontWeight.bold)),
  ],
),
In OnboardingScreen (above title):

dart
Copy code
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Image.asset('assets/logo.png', width: 32, height: 32),
    const SizedBox(width: 8),
    Text(page.title, style: TextStyle(color: Colors.white)),
  ],
),
🛠 Tech Stack
Flutter & Dart

Lottie

Gemini API integration

Dark/light theming
