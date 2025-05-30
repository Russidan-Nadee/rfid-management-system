import 'package:flutter/material.dart';
import 'package:frontend/core/app_theme.dart';
import 'package:frontend/presentation/root_layout.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern App',
      theme: appTheme,
      home: const RootLayout(),
    );
  }
}
