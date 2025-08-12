# 🤖 BotBuddy – AI Chat Assistant

A Flutter AI chat app powered by the **Gemini API** with chat history, dark/light mode, and a modern animated UI.

---

## 🚀 Demo
🔗 **Live App:** [Try BotBuddy](http://elaborate-hamster-77b81b.netlify.app)

---

## ✨ Features
- Dark/Light Mode toggle  
- Save & Clear Chat History  
- Start New Chat  
- Lottie animated onboarding  
- Custom logo & app name  

---

## 📂 Quick Setup
```bash
git clone https://github.com/Utkarshkhotele/BotBuddy.git
cd BotBuddy
flutter pub get
flutter run
Add assets in pubspec.yaml:

yaml
Copy code
assets:
  - assets/logo.png
  - assets/chatbot.json
Change app name:

Android: android/app/src/main/res/values/strings.xml

iOS: ios/Runner/Info.plist

Set launcher icon:

bash
Copy code
flutter pub run flutter_launcher_icons:main


🛠 Tech
Flutter • Dart • Lottie • Gemini API
