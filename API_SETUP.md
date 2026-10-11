# API setup notes

1. Choose a football data provider that explicitly covers your required leagues and statistics.
2. Read the provider documentation for fixtures/matches endpoint, authentication header, rate limits, and response schema.
3. Paste the exact endpoint and API key in app Settings for the starter adapter.
4. If your provider's response differs from `matches`, `response`, or `data` arrays, edit `FootballApi.fetchMatches` in `lib/main.dart`.
5. For a public production app, proxy sensitive API keys through a backend. Never commit secrets to GitHub.

Career totals by club/season, injury reports and estimated return dates may need additional endpoints or a different subscription tier. Predictions should be computed from historical data and validated; don't display arbitrary percentages as model output.
