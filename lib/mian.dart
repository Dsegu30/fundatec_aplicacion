
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF6F8FA),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TecApp());
}

class TecApp extends StatelessWidget {
  const TecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEC Móvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF083D91),
          brightness: Brightness.light,
        ),
      ),
      home: const TecHomeScreen(),
    );
  }
}
