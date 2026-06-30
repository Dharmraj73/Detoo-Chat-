lib/main.dart# Detoo Chat App 🇮🇳

WhatsApp jaisa chatting app — 1-on-1 chat, group chat, photo/file sharing, aur voice/video calling. India ke liye banaya gaya (+91 phone login, Hindi text).

## Features
- ✅ Phone number (+91) se OTP login
- ✅ 1-on-1 chat
- ✅ Group chat
- ✅ Photo & file sharing
- ✅ Voice & video calling (Agora)
- ✅ Real-time messaging (Firebase Firestore)

## Setup Karne Ke Steps

### 1. Flutter Install Karein
Agar Flutter nahi hai computer me:
- https://docs.flutter.dev/get-started/install se download karein
- `flutter doctor` chala kar check karein sab sahi hai

### 2. Project Dependencies Install Karein
```bash
cd detoo_chat_app
flutter pub get
```

### 3. Firebase Project Banayein (Backend ke liye — FREE hai)
1. https://console.firebase.google.com par jaakar naya project banayein
2. Project me **Authentication** enable karein → Sign-in method me **Phone** enable karein
3. **Firestore Database** banayein (test mode me start kar sakte hain)
4. **Storage** enable karein (photo/file upload ke liye)
5. Apne computer me Firebase CLI install karein:
   ```bash
   dart pub global activate flutterfire_cli
   ```
6. Project root me ye command chalayein (ye automatically `firebase_options.dart` file bana dega):
   ```bash
   flutterfire configure
   ```
7. `lib/main.dart` me `Firebase.initializeApp()` ko update karein:
   ```dart
   import 'firebase_options.dart';
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

### 4. Agora Account Banayein (Voice/Video Call ke liye — FREE tier available)
1. https://www.agora.io par sign up karein
2. Naya project banayein, **App ID** copy karein
3. `lib/services/call_service.dart` file kholein
4. `YOUR_AGORA_APP_ID` ko apne actual App ID se replace karein

**Important (Production ke liye):** Agora token authentication backend server se generate karna chahiye security ke liye. Testing ke liye App ID akela bhi kaam karta hai (token-less mode), lekin Play Store pe publish karne se pehle proper token server banayein — Agora docs me poora guide hai.

### 5. App Run Karein
```bash
flutter run
```

### 6. Play Store Pe Publish Karne Ke Liye
1. App ka signed APK/App Bundle banayein:
   ```bash
   flutter build appbundle --release
   ```
2. Google Play Console (https://play.google.com/console) par developer account banayein (one-time $25 fee)
3. App bundle upload karein, store listing (screenshots, description) fill karein
4. Review ke liye submit karein (usually 1-7 din lagte hain)

## Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (User, Chat, Message)
├── services/                 # Firebase, Chat, Call logic
└── screens/                  # All UI screens
```

## Zaroori Notes
- **Firestore Security Rules** zaroor set karein production se pehle (abhi test mode me hai, koi bhi data padh/likh sakta hai)
- **Agora token server** zaroor banayein production launch se pehle
- App icon, splash screen image, aur app name "Detoo" customize karne ke liye `assets/` folder use karein
- Costs: Firebase free tier kaafi hai shuru me, Agora bhi free minutes deta hai monthly

## Help Chahiye?
Agar koi specific feature add karna hai (status/stories, voice messages, end-to-end encryption, dark mode, etc.) ya kisi step me atak gaye hain, bata sakte hain — aage madad kar sakta hoon.
