# AI Redakcia Frontend (files bundle)

This ZIP contains the `lib/` folder plus a minimal `pubspec.yaml` with required dependencies.

## Quick start
1) Create a Flutter project:
   flutter create ai_redakcia_frontend

2) Copy the included `lib/` into the project root (overwrite existing `lib/`).

3) Merge dependencies from the included `pubspec.yaml` into your project's `pubspec.yaml`.

4) Run:
   flutter pub get
   flutter run

## Backend endpoints used (change base URL in lib/core/state.dart)
- POST /v1/topics/suggest
- POST /v1/content/generate
- GET  /v1/history?youtube=...&tiktok=...&telegram=...
