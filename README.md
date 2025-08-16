samples, guidance on mobile development, and a full API reference.

# Spin It Flutter

> A fun, interactive party game built with Flutter. Spin the bottle, answer truth questions, and challenge your friends!

## Features

- Spin the bottle with swipe gestures
- Animated bottle spin and zoom effects
- Truth questions loaded from a JSON file (easy to customize)
- Score tracking for two players
- Choose your bottle design
- Beautiful, modern UI
- Works on Android, iOS, and web

## Screenshots

_Add your screenshots here!_

## How to Play

1. Swipe left or right to spin the bottle.
2. When the bottle stops, a random truth question appears for the selected player.
3. Answer the question or skip (the other player gets a point if you skip).
4. First to reach your chosen score wins!

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android/iOS device or emulator, or run on web

### Setup
1. Clone this repo:
	```sh
	git clone https://github.com/BorisDmv/spin-it-flutter.git
	cd spin-it-flutter
	```
2. Install dependencies:
	```sh
	flutter pub get
	```
3. Run the app:
	```sh
	flutter run
	```

### Assets
Make sure the following are included in your `pubspec.yaml`:
```yaml
  assets:
	 - assets/bottle1.png
	 - assets/bottle3.png
	 - assets/questions.json
```

## Customizing Questions
Edit `assets/questions.json` to add, remove, or change truth questions.

## Contributing
Pull requests and suggestions are welcome! Feel free to open issues for bugs or feature requests.

## License
MIT
