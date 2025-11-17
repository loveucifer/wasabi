# WASABI - Widget Builder

A Flutter mobile app that uses Google Gemini AI to generate beautiful, animated home screen widgets from natural language descriptions.

## Features

- **AI-Powered Widget Generation**: Describe your widget in plain language and let Gemini AI create it
- **Rich Animations**: Widgets come alive with fade, scale, slide, pulse, bounce, and more animation effects
- **Multiple Themes**: Choose from minimal, gradient, glass, material, and neon themes
- **Flexible Sizing**: Create small (158×158), medium (338×158), or large (338×354) widgets
- **Live Data Bindings**: Widgets can display real-time data like time, date, battery, weather, and more
- **Visual Editor**: Preview your widgets before adding them to your home screen
- **Secure Storage**: API keys are stored securely using flutter_secure_storage

## Getting Started

### Prerequisites

- Flutter SDK (3.11+)
- iOS device/simulator or Android device/emulator
- Google Gemini API key ([Get it here](https://makersuite.google.com/app/apikey))

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### First Launch

1. The app will prompt you to enter your Gemini API key
2. Enter your key and tap "Continue"
3. You'll be taken to the home screen where you can create your first widget

## Usage

### Creating a Widget

1. Tap the **+** button on the home screen
2. Describe your widget in natural language
   - Example: "Show current weather with temperature and animated sun icon"
   - Example: "Display step count with progress bar and gradient background"
3. Customize options (optional):
   - **Size**: Small, Medium, or Large
   - **Theme**: Minimal, Gradient, Glass, Material, or Neon
4. Tap **Generate Widget**
5. Preview your widget and tap **Add to Home Screen**

### Managing Widgets

- **View**: Tap any widget card on the home screen to preview it
- **Delete**: Long press a widget card to delete it
- **Settings**: Tap the gear icon to manage your API key or clear all data

## Architecture

### Project Structure

```
lib/
├── models/          # Data models (WidgetModel, WidgetSpec, etc.)
├── providers/       # State management (Provider pattern)
├── screens/         # UI screens
├── services/        # Business logic (Gemini, Database, Storage)
├── theme/           # Design system (colors, typography, animations)
├── widgets/         # Reusable widgets (WidgetRenderer)
└── main.dart        # App entry point
```

### Key Technologies

- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **SQLite**: Local database for widget storage
- **Flutter Secure Storage**: Encrypted API key storage
- **Google Generative AI**: Gemini API for widget generation
- **home_widget**: Native widget integration (iOS & Android)

## Design Principles

WASABI follows a modern, minimalist design with:

- **Monochrome UI**: Pure black and white with gray scale accents
- **Smooth Animations**: 60fps animations using Flutter's AnimationController
- **Visual Hierarchy**: Typography scale from 12pt to 48pt
- **Elevation System**: 4 levels of depth with progressive shadows
- **4pt Grid**: Consistent spacing throughout the app

## Widget Animations

Widgets support 8 animation types:

1. **Fade**: Opacity transitions
2. **Scale**: Size transformations
3. **Slide**: Positional movement
4. **Rotate**: Rotation transforms
5. **Pulse**: Breathing scale effect
6. **Bounce**: Spring-based entrance
7. **Shimmer**: Gradient sweep for loading
8. **CountUp**: Numerical value animations

## Contributing

Contributions are welcome! Please follow the existing code style and design patterns.

## License

This project is built for demonstration purposes.
