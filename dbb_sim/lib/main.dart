import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'features/ble/ble_service.dart';
import 'features/balance/balance_provider.dart';
import 'features/settings/settings_provider.dart';
import 'ui/screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DBBSimApp());
}

class DBBSimApp extends StatelessWidget {
  const DBBSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // BLE Service provider
        ChangeNotifierProvider<BleService>(
          create: (_) => BleService(),
        ),
        // Settings provider
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        // Balance provider (depends on BleService)
        ChangeNotifierProxyProvider<BleService, BalanceProvider>(
          create: (context) => BalanceProvider(
            context.read<BleService>(),
          ),
          update: (context, bleService, previous) =>
              previous ?? BalanceProvider(bleService),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'DBBSim',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: '/',
            routes: {
              '/': (context) => const BalanceDeskScreen(),
              '/devices': (context) => const BleDevicesScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/session-summary': (context) => const SessionSummaryScreen(),
              '/about': (context) => const AboutScreen(),
            },
          );
        },
      ),
    );
  }
}
