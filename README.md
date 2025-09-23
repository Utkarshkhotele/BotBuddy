# 🤖 BotBuddy – AI Chat Assistant  

> **An intelligent chat app built with Flutter, powered by Google's Gemini API, featuring modern animations, persistent chat history, and customizable themes.**  

---

## 🚀 Demo  
🔗 **Live App:** [Try BotBuddy](http://elaborate-hamster-77b81b.netlify.app)  
---

## ✨ Features  
✅ **Dark/Light Mode Toggle** – Switch themes instantly  
✅ **Save & Clear Chat History** – Persistent conversations with option to clear  
✅ **Start New Chat** – Reset and start fresh anytime  
✅ **Lottie Animated Onboarding** – Smooth and modern welcome screen  
✅ **Custom Logo & App Name** – Personalized branding for your app  
✅ **Responsive UI** – Works on mobile, tablet, and desktop  
✅ **Offline Safe** – Chat history remains even without internet  

---

## 🛠 Tech Stack  
- **Flutter** – Cross-platform app framework  
- **Dart** – Programming language  
- **Gemini API** – AI chat intelligence  
- **Lottie** – Animation assets  
- **Hive** – Local NoSQL storage for chat history  
- **Provider + BLoC** – State management  

---

# 📦 Quick Start

```bash
# Clone the repository
git clone https://github.com/Utkarshkhotele/BotBuddy.git

# Navigate into the folder
cd BotBuddy

# Get packages
flutter pub get

# Run the app
flutter run


🧠 How It Works
User sends a message — captured via Flutter chat UI.
Message sent to Gemini API — processed for AI response.
AI responds — displayed in chat bubble and stored locally in Hive DB.
Theme and chat history — managed via Provider & BLoC for smooth performance.


👨‍💻 Contributing
Contributions are welcome!
Fork the repo
Create your branch: git checkout -b feature-name
Commit your changes: git commit -m 'Add new feature'
Push to the branch: git push origin feature-name
Submit a Pull Request 🚀
