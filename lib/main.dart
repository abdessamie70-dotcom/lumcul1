import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/cable_sizing_provider.dart';
import 'providers/lighting_provider.dart';
import 'providers/short_circuit_provider.dart';
import 'screens/main_shell.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LightingProvider()),
        ChangeNotifierProvider(create: (_) => CableSizingProvider()),
        ChangeNotifierProvider(create: (_) => ShortCircuitProvider()),
      ],
      child: const LightingCalculatorApp(),
    ),
  );
}

class LightingCalculatorApp extends StatelessWidget {
  const LightingCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LightingProvider>();

    return MaterialApp(
      title: 'LUMCAL APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.themeMode,

      // إعدادات اللغات المدعومة (العربية والإنجليزية)
      locale: provider.locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ضبط اتجاه النص ديناميكياً (RTL للعربية و LTR للإنجليزية)
      builder: (context, child) {
        return Directionality(
          textDirection: provider.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const MainShell(),
    );
  }
}
