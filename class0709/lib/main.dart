import 'package:class0709/Presentation/screens/home_screen.dart';
import 'package:class0709/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter clase 0709',
      theme: AppTheme().themeData(),
      home: HomeScreen(),
    );
  }
}