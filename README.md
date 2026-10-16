# My Vocabulary — Flutter App

A simple local vocabulary notebook. For every word you save, you can store:

- The word itself
- বাংলা অর্থ (Bangla meaning)
- Similar words (synonyms)
- Opposite words (antonyms)
- An example sentence

Data is stored locally on the device using **SQLite** (`sqflite`), so it persists between app restarts with no backend/internet required.

## Project structure

```
lib/
  main.dart                      # App entry point, theme
  models/
    word_entry.dart              # WordEntry data model
  services/
    database_helper.dart         # SQLite CRUD (sqflite)
  screens/
    home_screen.dart             # List + search + FAB
    add_edit_word_screen.dart    # Add/Edit form
    word_detail_screen.dart      # Full detail view
  widgets/
    word_list_item.dart          # Swipe-to-delete list card
```

## Setup

1. Make sure you have the Flutter SDK installed: https://docs.flutter.dev/get-started/install
2. Unzip this project, then from the project root run:

   ```bash
   flutter pub get
   flutter run
   ```

   This will launch on whichever device/emulator/simulator you have connected (or in Chrome if you run `flutter run -d chrome` — note: sqflite needs a platform-specific shim for web, so for web support you'd swap in `sqflite_common_ffi_web`; this build targets Android/iOS/desktop out of the box).

3. To build a release APK:

   ```bash
   flutter build apk --release
   ```

## Features

- **Add word** — floating action button opens a form (word, Bangla meaning, synonyms, antonyms, example sentence). Only word + Bangla meaning are required.
- **Search** — live search across word, Bangla meaning, and synonyms.
- **Detail view** — tap any word to see everything, with synonyms/antonyms shown as chips.
- **Edit** — edit icon on the detail screen.
- **Delete** — swipe a list item left, with a confirmation dialog.
- **Synonyms/antonyms** are stored as comma-separated text (e.g. `happy, glad, joyful`) and automatically split into chips for display — no extra tables needed.

## Extending it

Ideas if you want to grow this later:
- Add categories/tags (e.g. IELTS, GRE, daily-use)
- Add a "mark as learned" / spaced-repetition flag
- Export/import word list as JSON or CSV
- Add text-to-speech pronunciation for the English word
