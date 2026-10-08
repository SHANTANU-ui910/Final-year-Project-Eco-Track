# EcoTra - Production-Quality Sustainability & Transportation Tracking App

Built with **Flutter (Dart)** & **Riverpod**, designed to meet senior product design standards (resembling Strava + Apple Health + a premium eco product).

---

## 🚀 Key Features Built in this Module

1. **Immersive Live Tracking**:
   - Dynamic animated vehicle widget with real-time speed reactivity (CustomPainter: rotating wheel spokes, vertical micro-bounce, road dashes, speed wind streaks).
   - High-precision live metrics with animated number tweening (Current Speed, Distance, Carbon Output in kg CO₂e, Elapsed Duration).
   - Real-time carbon accumulation gauge with progress thresholds.
   - Live Google Maps route polyline tracking with auto-centering.

2. **Vehicle & Transit Mode Selection**:
   - Bottom sheet picker with 8 distinct modes: Petrol Car, Diesel Car, Electric Vehicle (EV), Motorcycle, Public Bus, Train / Metro, Bicycle, and Walking.
   - Live preview of standardized emission factors ($kg\ CO_2e\ /\ km$) sourced from DEFRA environmental databases.

3. **Trip Summary & Logbook**:
   - Post-trip summary card with total distance, duration, carbon emitted, and carbon avoided vs. conventional petrol vehicle.
   - Offline-first persistence powered by Hive.
   - Comprehensive trip history screen with metrics aggregation and zero-emission filtering.
   - Detailed trip drilldown with route map visualization and granular stats.

---

## 📂 Architecture & Folder Structure

```
c:\Eco track build\
├── lib/
│   ├── main.dart                                  # App initialization & ProviderScope
│   ├── app.dart                                   # Root MaterialApp & ThemeMode
│   ├── core/
│   │   ├── constants/
│   │   │   └── emission_factors.dart              # DEFRA emission factors table & formulas
│   │   └── theme/
│   │       ├── app_colors.dart                    # Forest green, sage, charcoal palette
│   │       ├── app_text_styles.dart               # Inter / SF Pro typography hierarchy
│   │       └── app_theme.dart                     # Material 3 Light & Dark themes
│   └── features/
│       └── transportation/
│           ├── models/
│           │   ├── vehicle_type.dart              # Modes enum with emission properties
│           │   ├── location_point.dart            # Lat/Lng/Speed/Timestamp model
│           │   └── trip_model.dart                # Persisted trip entity
│           ├── services/
│           │   ├── location_service.dart          # Geolocator stream & Haversine distance
│           │   └── trip_storage_service.dart      # Hive offline-first local database
│           ├── providers/
│           │   ├── tracking_provider.dart         # Live tracking Riverpod state notifier
│           │   └── trip_history_provider.dart     # History logbook Riverpod provider
│           ├── widgets/
│           │   ├── vehicle_animation_widget.dart  # Speed-reactive moving vehicle CustomPainter
│           │   ├── live_metrics_widget.dart       # Animated number counter metric tiles
│           │   ├── live_map_widget.dart           # Google Maps polyline route renderer
│           │   ├── carbon_chart_widget.dart       # Real-time carbon accumulation bar
│           │   ├── trip_controls_widget.dart      # Pause/Resume and Stop trip FABs
│           │   └── trip_card_widget.dart          # History log card item
│           └── screens/
│               ├── transportation_hub_screen.dart # Mobility Hub with hero CTA & stats
│               ├── vehicle_selector_screen.dart   # Transit mode bottom sheet
│               ├── live_tracking_screen.dart      # Full-screen immersive live tracking
│               ├── trip_summary_screen.dart       # Post-trip stats & save/discard
│               ├── trip_history_screen.dart       # History log with filters
│               └── trip_detail_screen.dart        # Route map & detailed trip stats
├── test/
│   └── emission_factor_test.dart                  # Calculation unit tests
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🛠️ How to Run

1. **Prerequisites**: Ensure Flutter SDK is installed and added to your `PATH`.
2. Run in terminal:
   ```bash
   flutter pub get
   ```
3. To run unit tests:
   ```bash
   flutter test
   ```
4. Configure Google Maps:
   - For Android: Add your API key in `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data android:name="com.google.android.geo.API_KEY"
                android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
     ```
   - For iOS: Add your API key in `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
     ```
5. Launch the application:
   ```bash
   flutter run
   ```

