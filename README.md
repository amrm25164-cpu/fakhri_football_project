# Fakhri Football

Flutter/Dart starter project for an Arabic football companion app.

## Features currently included
- Arabic RTL-friendly dark UI and bottom navigation
- Home dashboard and feature areas
- Matches page with configurable API endpoint/key
- League directory placeholder
- Analytics, prediction, player comparison and injury feature descriptions
- Local settings persistence using shared_preferences
- HTTP request starter adapter for common response shapes

## Important limitations
This is a complete starter structure, not a fully data-integrated commercial product. Each football-data provider has a different schema and coverage. Adapt `FootballApi.fetchMatches` to the selected provider's documented endpoint/response. Injury return dates, full career statistics, broadcast channels, live scores, and prediction probabilities require reliable data sources. No sample results are represented as real.

## Run
1. Install Flutter SDK and Android build tools in a supported environment.
2. Run `flutter pub get`
3. Run `flutter run` or `flutter build apk --release`

If building from an Android-only IDE, use its documented cloud build/GitHub Actions workflow. Do not commit API keys to a public repository.
