import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/cable_sizing_provider.dart';
import 'providers/lighting_provider.dart';
import 'screens/main_shell.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LightingProvider()),
        ChangeNotifierProvider(create: (_) => CableSizingProvider()),
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
      title: 'حاسبة الإضاءة المنزلية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.themeMode,

      // إعدادات اللغة العربية ودعم الاتجاه من اليمين لليسار (RTL)
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ضمان اتجاه النص RTL على مستوى كامل شاشات التطبيق
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const MainShell(),
    );
  }
}
