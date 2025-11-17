import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasabi/providers/api_key_provider.dart';
import 'package:wasabi/providers/widget_provider.dart';
import 'package:wasabi/providers/generation_provider.dart';
import 'package:wasabi/screens/splash_screen.dart';
import 'package:wasabi/screens/api_setup_screen.dart';
import 'package:wasabi/screens/home_screen.dart';
import 'package:wasabi/screens/generator_screen.dart';
import 'package:wasabi/screens/preview_screen.dart';
import 'package:wasabi/screens/settings_screen.dart';
import 'package:wasabi/theme/theme.dart';
import 'package:wasabi/models/widget_model.dart';

void main() {
  runApp(const WasabiApp());
}

class WasabiApp extends StatelessWidget {
  const WasabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiKeyProvider()),
        ChangeNotifierProvider(create: (_) => WidgetProvider()),
        ChangeNotifierProvider(create: (_) => GenerationProvider()),
      ],
      child: MaterialApp(
        title: 'WASABI',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
            case '/api-setup':
              return MaterialPageRoute(
                builder: (_) => const ApiSetupScreen(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
            case '/generator':
              return MaterialPageRoute(
                builder: (_) => const GeneratorScreen(),
              );
            case '/preview':
              final widget = settings.arguments as WidgetModel?;
              return MaterialPageRoute(
                builder: (_) => PreviewScreen(widget: widget),
              );
            case '/settings':
              return MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
          }
        },
      ),
    );
  }
}
