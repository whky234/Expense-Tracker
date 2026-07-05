# expense_tracker

A Flutter expense tracker with Firebase authentication, budgets, categories, and expense management.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A Firebase project

### Firebase setup

Firebase config files are not committed to this repo. Generate them locally:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This creates `lib/firebase_options.dart` and platform config files (for example `android/app/google-services.json`). See the `.example` files in the repo for the expected structure.

### Run the app

```bash
flutter pub get
flutter run
```

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [FlutterFire setup](https://firebase.google.com/docs/flutter/setup)
