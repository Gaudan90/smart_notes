# 📝 Smart Notes v1.0.0

**All-in-one productivity toolkit for Android — to-do lists, habits, expenses, passwords, meal plans, and much more.**

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/flutter-3.7+-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/dart-3.7+-0175C2.svg?logo=dart)
![License](https://img.shields.io/badge/license-MIT-orange.svg)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84.svg?logo=android)
![Languages](https://img.shields.io/badge/languages-9-brightgreen.svg)

**Author:** Gaudan90

---

## 📋 Table of Contents

- [Description](#-description)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Languages](#-languages)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Privacy Policy](#-privacy-policy)
- [FAQ](#-faq)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## 📖 Description

**Smart Notes** is a feature-rich productivity app that brings together 16+ everyday tools in a single, beautifully designed application. Instead of installing dozens of single-purpose apps, Smart Notes provides everything you need — from task management and habit tracking to secure password generation and meal planning.

### Why Smart Notes?

- **One App, Many Tools**: 16+ features covering productivity, time management, security, and more
- **Fully Offline**: All data is stored locally on your device — no accounts, no cloud, no tracking
- **Beautiful Themes**: Material Design 3 with custom color picker, dark mode, and color-blind accessibility
- **Truly Multilingual**: 9 languages with 700+ translation keys, respecting your system locale
- **Clean Architecture**: Built with maintainability and quality in mind, not just thrown together

---

## ✨ Features

### 📋 Productivity & Organization

- ✅ **To-Do List** — Create, complete, and delete tasks with swipe-to-dismiss. Confirmation dialogs prevent accidental deletions. Validation feedback on empty inputs.
- ✅ **Habit Tracker** — Track daily habits on a monthly calendar grid with completion tracking, gap detection, and detailed statistics. Locale-aware day-of-week display.
- ✅ **Shopping List** — Manage quantity- and weight-based items with duplicate detection, purchase history, alphabetical sorting, and multi-select batch deletion. Includes a **Supermarkets tab** with nine predefined stores, purchase logging, and TXT import/export.
- ✅ **Expense Tracker** — Log and categorize expenses with statistics and visual breakdowns to keep your budget under control.
- ✅ **Mini Planner (Gantt)** — Task management with timeline visualization, status tracking (to-do, in progress, done), and daily push notifications at 18:00 with per-task toggles.
- ✅ **Meal Plan** — Plan your weekly meals organized by dish categories, meal types, and days of the week.

### ⏱️ Time Management

- ✅ **Countdown Timers** — Full CRUD with real-time updates, color-coded urgency, emoji selection via visual picker, and search/filter capabilities.
- ✅ **Reminders** — Set reminders with push notifications to stay on top of important events and deadlines.
- ✅ **Event Calendar** — Generate recurring events (daily, weekly, monthly) with full date generation and detailed occurrence views.

### 🔐 Security & Utilities

- ✅ **Password Generator** — Generate secure passwords with configurable options (length, uppercase, lowercase, numbers, symbols). Includes a PIN-protected history (8-digit PIN + security question, SHA-256 hashing), password strength indicator, and **export to PDF/TXT** via share sheet or direct save to device storage.
- ✅ **Text Analyzer** — Analyze any text with detailed statistics: character count, word count, sentence count, and more. Keeps a searchable history of past analyses.
- ✅ **Dice Roller** — Roll any combination of dice from d2 to d100 with shake animations, NAT 20 / CRIT FAIL highlights, compact multi-die display, and roll history.

### 🧠 Learning & Logic Tools

- ✅ **Routine Planner (FizzBuzz)** — An interactive take on the classic algorithm, doubling as a pattern-based planning tool.
- ✅ **Number Statistics** — Input a set of numbers and get instant analysis: mean, median, mode, range, frequency distribution, and more.
- ✅ **Sentence Reverser** — Reverse words or characters in any sentence — useful for text manipulation exercises and learning.
- ✅ **Missing Numbers** — Find missing numbers in a sequence, a handy tool for logical reasoning practice.

### 🎨 Customization & Accessibility

- ✅ **Theme Settings** — Light, dark, or system theme. Pick from 8 built-in colors or create unlimited custom colors with a visual HSL picker. Color names displayed beneath each swatch. Remove custom colors anytime.
- ✅ **Color-Blind Modes** — Four accessibility modes (None, Protanopia, Deuteranopia, Tritanopia) with real-time color filter applied across the entire app.
- ✅ **Onboarding** — A guided introduction on first launch to help new users discover all features at a glance.

---

## 📸 Screenshots

<p align="center">
  <img src="https://i.postimg.cc/MTfx4cL6/Screenshot-20260305-234456.png" width="250" alt="Home Screen One" />
  &nbsp;&nbsp;
  <img src="https://i.postimg.cc/QtKsPBzM/Screenshot-20260305-234523.png" width="250" alt="Home Screen Two" />
  &nbsp;&nbsp;
  <img src="https://i.postimg.cc/gJLd5w7J/Screenshot-20260305-234535.png" width="250" alt="Home Screen Three" />
</p>

---

## 🌍 Languages

Smart Notes supports **9 languages** out of the box with **700+ translation keys**:

| Language | Code | Status |
|----------|------|--------|
| 🇬🇧 English | `en-US` | ✅ Complete |
| 🇮🇹 Italian | `it-IT` | ✅ Complete |
| 🇫🇷 French | `fr-FR` | ✅ Complete |
| 🇩🇪 German | `de-DE` | ✅ Complete |
| 🇪🇸 Spanish | `es-ES` | ✅ Complete |
| 🇨🇳 Chinese (Simplified) | `zh-CN` | ✅ Complete |
| 🇹🇷 Turkish | `tr-TR` | ✅ Complete |
| 🇸🇦 Arabic | `ar-SA` | ✅ Complete |
| 🇷🇺 Russian | `ru-RU` | ✅ Complete |

The app respects your system locale for date formats and day-of-week display.

---

## 💻 Requirements

### System Requirements

- **Platform**: Android 6.0 (API 23) or higher
- **Storage**: ~30 MB for installation
- **Permissions**: Notifications (optional, for reminders and planner alerts)

### For Development

- **Flutter SDK**: ^3.7.2
- **Dart SDK**: ^3.7.2
- **Android Studio** or **VS Code** with Flutter extension
- **JDK**: 17+ for Android builds

---

## 📦 Installation

### Option 1: Google Play Store (Recommended)

> *Coming soon — the app will be available on Google Play Store.*

### Option 2: Build from Source

```bash
# Clone repository
git clone https://github.com/yourusername/smart_notes.git
cd smart_notes

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

The release APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

### Option 3: Direct APK

Download the latest APK from the [Releases](https://github.com/yourusername/smart_notes/releases) page.

---

## 🏗️ Architecture

Smart Notes follows **Clean Architecture** with a strict separation of concerns and the **MVP (Model-View-Presenter)** pattern throughout.

### Project Structure

```
lib/
├── main.dart                  # App entry point & routing
│
├── controllers/               # Presenters — all business logic
│   ├── todo_presenter.dart
│   ├── habit_tracker_presenter.dart
│   ├── shopping_list_presenter.dart
│   ├── expense_presenter.dart
│   ├── password_generator_presenter.dart
│   ├── countdown_presenter.dart
│   ├── meal_plan_presenter.dart
│   ├── gantt_planner_presenter.dart
│   ├── dice_roller_presenter.dart
│   └── ...
│
├── states/                    # Models — pure data classes
│   ├── todo_model.dart
│   ├── habit_model.dart
│   ├── shopping_item_model.dart
│   ├── expense_model.dart
│   ├── password_model.dart
│   └── ...
│
├── screens/                   # Views — UI screens
│   ├── home_view.dart
│   ├── todo_list_view.dart
│   ├── habit_tracker_view.dart
│   ├── shopping_list_view.dart
│   └── ...
│
├── widget/                    # Reusable extracted widgets
│   ├── password/              # Password feature widgets
│   ├── shopping/              # Shopping feature widgets
│   ├── dice/                  # Dice roller widgets
│   ├── theme/                 # Theme settings widgets
│   └── feature_card.dart      # Home grid card
│
├── data/                      # Services & data access
│   ├── password_export_service.dart
│   ├── notification_service.dart
│   └── gantt_notification_service.dart
│
└── theme/                     # Theme configuration
    ├── theme_config.dart       # Light & dark theme definitions
    ├── theme_provider.dart     # ChangeNotifier for theme state
    ├── color_blind_mode.dart   # Color-blind filter definitions
    └── color_picker_painter.dart
```

### Key Principles

- **Single responsibility**: One class per file, max ~500 lines — extract widgets when exceeded
- **No silent failures**: Every user input provides validation feedback (SnackBar)
- **Confirmation before destruction**: Delete, clear, and remove actions always require user confirmation
- **Type safety**: Enums with extension methods for translations and state management
- **Locale respect**: System locale used for dates and formatting — never hardcoded

---

## 🔧 Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.7+ with Material Design 3 |
| **State Management** | ChangeNotifier (ThemeProvider) |
| **Persistence** | SharedPreferences, Flutter Secure Storage |
| **Notifications** | flutter_local_notifications + timezone |
| **Localization** | easy_localization (9 languages) |
| **Security** | SHA-256 hashing (crypto), Flutter Secure Storage |
| **Export** | pdf (PDF generation), share_plus, file_picker |
| **UI** | Material 3, custom color picker, animated transitions |

### Dependencies

**Core:**
- `shared_preferences` — Local key-value storage
- `flutter_secure_storage` — Encrypted storage for PIN
- `crypto` — SHA-256 hashing for PIN security
- `easy_localization` — Multi-language support

**Notifications & Time:**
- `flutter_local_notifications` — Push notifications
- `timezone` / `flutter_timezone` — Timezone-aware scheduling
- `permission_handler` — Runtime permission management

**Export & Sharing:**
- `pdf` — PDF document generation
- `share_plus` — Native share sheet
- `file_picker` — Directory picker for save-to-device
- `path_provider` — Temp directory access

---

## 🔒 Privacy Policy

Smart Notes takes your privacy seriously.

- **No data collection**: The app does not collect, transmit, or share any personal data
- **Fully offline**: All data is stored locally on your device using SharedPreferences and Flutter Secure Storage
- **No analytics**: No tracking, no telemetry, no third-party analytics SDKs
- **No accounts**: No registration, no login, no cloud sync
- **No ads**: The app is completely ad-free
- **PIN security**: Your password history is protected by an 8-digit PIN stored as a SHA-256 hash — the actual PIN is never stored

For the full privacy policy, see [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

---

## ❓ FAQ

### General Questions

**Q: Is Smart Notes free?**
A: Yes, Smart Notes is completely free with no ads and no in-app purchases.

**Q: Does Smart Notes require an internet connection?**
A: No. Smart Notes is fully offline. All data stays on your device.

**Q: What happens if I uninstall the app?**
A: All locally stored data will be deleted. Consider exporting your passwords (PDF/TXT) before uninstalling.

**Q: Can I transfer my data to a new phone?**
A: Currently, Smart Notes stores data locally. You can export passwords via PDF/TXT and shopping lists via TXT. Full backup/restore is on the roadmap.

### Feature Questions

**Q: I forgot my password PIN. How do I recover it?**
A: Use the security question you set during PIN creation. If you also forgot the answer, you'll need to reset the PIN — this will clear your password history.

**Q: Can I add more than 8 default colors?**
A: Yes! Use the custom color picker to add unlimited colors with the HSL visual selector. You can also remove them anytime.

**Q: How do notifications work for the Mini Planner?**
A: The Mini Planner sends daily notifications at 18:00 local time for tasks that have notifications enabled. You can toggle notifications per task.

**Q: Can I change the app language?**
A: Yes. Tap the language button (EN/IT) in the top-left corner of the home screen. The app also supports French, German, Spanish, Chinese, Turkish, Arabic, and Russian — these follow your device's system language.

---

## 🗺️ Roadmap

Future features under consideration:

- [ ] Full backup & restore (JSON export/import)
- [ ] Widgets for home screen (to-do, countdown, habit)
- [ ] iOS release
- [ ] Biometric authentication (fingerprint/face) for passwords
- [ ] Charts and graphs for expense tracker
- [ ] Recurring to-do items
- [ ] Cloud sync (optional, privacy-first)
- [ ] Tablet-optimized layouts
- [ ] Watch companion app

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Reporting Bugs

1. Check if the bug is already reported in Issues
2. Provide detailed information:
   - Device model and Android version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Suggesting Features

1. Open an issue with the `enhancement` label
2. Describe the feature and its use case
3. Explain how it would benefit users

### Code Contributions

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Follow the existing Clean Architecture patterns
4. Keep files under 500 lines — extract widgets when needed
5. Add translations for all 9 languages
6. Test thoroughly on both light and dark themes
7. Commit: `git commit -m 'Add amazing feature'`
8. Push: `git push origin feature/amazing-feature`
9. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 Gaudan90

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👤 Author

**Gaudan90**

- Professional mobile developer (Flutter, Kotlin Jetpack Compose, SwiftUI)
- Passionate about creative writing, tabletop gaming, and fantasy roleplay
- 20 years of experience managing play-by-forum RPG communities

---

## 📊 Version History

### v1.0.0 (Current)

- ✨ Initial release
- ✅ 16+ productivity tools in a single app
- ✅ Secure password generator with PIN-protected history
- ✅ PDF/TXT export with share sheet and save-to-device
- ✅ 9 language support (700+ keys)
- ✅ Material Design 3 with custom theme engine
- ✅ Color-blind accessibility modes
- ✅ Push notifications for planner and reminders
- ✅ Guided onboarding for first-time users
- ✅ Clean Architecture with MVP pattern

---

**Made with ❤️ in Flutter**

**Your productivity, your device, your privacy.** 📝✨
