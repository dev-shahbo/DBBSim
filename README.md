# DBBSim - Balance Desk Simulator

A Flutter application that visualizes and simulates 2D tilt/position on a square "desk" and communicates that data over BLE (Bluetooth Low Energy).

## Features

- **Balance Desk Visualization**: A square area with concentric circles showing safe, warning, and danger zones
- **Real-time Tilt Display**: Movable dot showing center of mass position based on roll/pitch angles
- **Dual Modes**:
  - **Live BLE Mode**: Receive tilt data from a connected Bluetooth device
  - **Manual Simulation Mode**: Drag the dot to simulate tilt values
- **Status Indicators**: Color-coded dot and status display (Stable/Slight tilt/High tilt)
- **Session Tracking**: Track balance metrics including max tilt and time in each zone
- **BLE Integration**: Scan, connect, and communicate with BLE balance devices
- **Settings**: Configurable notification period, max tilt angle, and calibration
- **Light/Dark Theme Support**: Automatically adapts to system theme

## Project Structure

```
dbb_sim/
├── lib/
│   ├── core/
│   │   ├── constants/       # App constants, BLE UUIDs, themes
│   │   ├── models/          # Data models (TiltData, Settings, etc.)
│   │   └── utils/           # Utility functions (tilt calculations, BLE parsing)
│   ├── features/
│   │   ├── balance/         # Balance state management
│   │   ├── ble/             # BLE service for device communication
│   │   └── settings/        # Settings state management
│   ├── ui/
│   │   ├── screens/         # App screens (BalanceDesk, Devices, Settings, etc.)
│   │   └── widgets/         # Reusable UI widgets
│   └── main.dart            # App entry point
├── test/                    # Unit and widget tests
└── android/                 # Android platform files
```

## Screens

| Route | Screen | Description |
|-------|--------|-------------|
| `/` | Balance Desk | Main visualization with tilt dot, info panel, and controls |
| `/devices` | BLE Devices | Scan and connect to BLE devices |
| `/settings` | Settings | Configure notification period, max tilt, calibration |
| `/session-summary` | Session Summary | View metrics from completed sessions |
| `/about` | About | App information and usage instructions |

## Balance Zones

- **Safe Zone (0-25%)**: Green - Stable position with minimal tilt
- **Warning Zone (25-50%)**: Yellow - Slight tilt detected
- **Danger Zone (>50%)**: Red - High tilt, balance at risk

## BLE Protocol

The app expects BLE devices to provide:
- **Tilt Service**: UUID `12345678-1234-5678-1234-56789abcdef0`
  - Tilt Characteristic (notify): Roll and pitch as float32 LE (8 bytes)
- **Battery Service**: Standard BLE Battery Service
  - Battery Level Characteristic: 0-100%

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator with BLE support

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/dev-shahbo/DBBSim.git
   cd DBBSim/dbb_sim
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Running Tests

```bash
flutter test
```

## Dependencies

- `provider`: State management
- `flutter_blue_plus`: BLE communication
- `shared_preferences`: Settings persistence
- `permission_handler`: Runtime permissions

## State Management

The app uses Provider for state management with three main providers:
- `BleService`: Manages BLE scanning, connection, and data streaming
- `BalanceProvider`: Manages tilt data, mode, and session metrics
- `SettingsProvider`: Manages app configuration and persistence

## Debug Features

- **Debug Simulator**: Enable in settings to generate fake tilt data for testing without hardware
- **Manual Mode**: Test UI and mapping without BLE connection

## License

This project is available for educational and personal use.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.