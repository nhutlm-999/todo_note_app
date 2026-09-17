# 📝 Todo & Note App

A modern, high-performance, and offline-first **Todo & Note-taking application** built with **Flutter** and **Dart**. Designed following **Clean Architecture (Feature-First)** and **Clean Code** principles, powered by **Flutter Riverpod (Notifier/NotifierProvider)** for robust and reactive state management.

---

## 🚀 Key Features

### 🎯 Task & Todo Management
- **Progress Tracking:** Real-time visual progress percentage with a dynamic `LinearProgressIndicator`.
- **Status Filtering:** Quickly filter tasks by `All`, `Active`, and `Completed`.
- **Category Tags:** Classify tasks into categories (`Work`, `Personal`, `Study`, `Shopping`, `Health`, etc.).
- **Priority Levels:** Color-coded priority indicators for `High` (Red), `Medium` (Amber), and `Low` (Emerald).
- **Due Date & Time:** Integrated Date and Time pickers with automatic overdue detection and badge indicators.
- **Swipe-to-Delete with Undo:** Intuitive dismissible swipe gesture with instant `SnackBar` undo support.

### 📝 Notes & Idea Pad (Google Keep Style)
- **Pinned Notes:** Pin crucial notes to automatically keep them at the top of the feed.
- **Pastel Color Palette:** Choose from 8 aesthetic pastel background colors for individual cards.
- **Hashtag System (`#tag`):** Attach customizable tags to notes and filter the feed dynamically.
- **Auto-save on Exit:** Powered by `PopScope` to seamlessly persist content whenever leaving the editor.

### ⚡ Global & System Features
- **Instant Search:** Real-time search query filtering across both tasks and notes.
- **Material 3 Design:** Fully adaptive Light & Dark theme toggle with modern typography and shape styling.
- **Offline-First Persistence:** Instant local storage powered by `SharedPreferences` (JSON serialization).
- **Zero-Warning Codebase:** 100% compliant with `flutter_lints`, tested with unit and widget test suites.

---

## 🏗️ Architecture & Design Patterns

The project follows **Clean Architecture** organized with a **Feature-First** approach:

```text
lib/
├── app/                                 # App-level configurations
├── core/                                # Shared cross-cutting concerns
│   ├── constants/                       # Color palettes, design tokens
│   ├── theme/                           # Material 3 Light & Dark themes
│   └── utils/                           # Pure utility functions (DateFormatter)
└── features/                            # Encapsulated feature modules
    ├── home/                            # Main navigation & tab orchestration
    │   └── presentation/views/          # HomeScreen (IndexedStack, NavigationBar)
    ├── todos/                           # Todo feature module
    │   ├── domain/models/               # Immutable entities (TodoModel)
    │   ├── data/                        # Repository pattern (TodoRepository)
    │   └── presentation/                # Riverpod Notifiers, UI Views & Widgets
    └── notes/                           # Note feature module
        ├── domain/models/               # Immutable entities (NoteModel)
        ├── data/                        # Repository pattern (NoteRepository)
        └── presentation/                # Riverpod Notifiers, UI Views & Widgets
```

### Data Flow Pipeline
```text
User Gesture (UI) ──> Notifier (Riverpod) ──> Repository (Storage)
     ▲                                                │
     └───────────── Automatic Rebuild (ref.watch) ────┘
```

- **Domain Layer:** Pure Dart classes with immutable fields (`final`), `copyWith()`, `toJson()`, and `fromJson()` factories.
- **Data Layer:** Repository Pattern isolating persistence logic from UI.
- **Presentation Layer:** State separation using `Notifier<T>` and derived `Provider` for optimal memoization and non-blocking search/filter computations.

---

## 📦 Tech Stack & Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod)** | `^3.4.3` | Reactive, compile-safe state management |
| **[shared_preferences](https://pub.dev/packages/shared_preferences)** | `^2.5.5` | Cross-platform local key-value persistence |
| **[uuid](https://pub.dev/packages/uuid)** | `^4.6.0` | Unique RFC4122 v4 identifier generation |
| **[intl](https://pub.dev/packages/intl)** | `^0.20.3` | Date formatting and localized time manipulation |
| **[cupertino_icons](https://pub.dev/packages/cupertino_icons)** | `^1.0.8` | Standard icon assets |
| **[flutter_lints](https://pub.dev/packages/flutter_lints)** | `^6.0.0` | Recommended static analysis rules |

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.24.0 or higher recommended)
- [Dart SDK](https://dart.dev/get-dart) (version 3.5.0 or higher)
- Android Studio, VS Code, or Xcode with Flutter plugins installed

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/todo_note_app.git
   cd todo_note_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run static analysis:**
   ```bash
   flutter analyze
   ```

4. **Run test suites:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   # Run on Chrome (Web)
   flutter run -d chrome

   # Run on macOS (Desktop)
   flutter run -d macos

   # Run on connected Mobile Emulator / Physical Device
   flutter run
   ```

---

## 🧪 Testing

The codebase includes automated unit and widget tests covering:
- Serialization & Deserialization (`TodoModel`, `NoteModel`)
- Model mutation safety with `copyWith`
- Date formatting and overdue status detection logic (`DateFormatter`)
- Widget smoke tests ensuring root view and navigation integrity

Run all tests via:
```bash
flutter test --reporter expanded
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues page](https://github.com/your-username/todo_note_app/issues).

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
