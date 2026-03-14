import 'package:flutter/material.dart';
import 'package:rpg_app/src/core/theme/app_theme.dart';
import 'package:rpg_app/src/features/home/presentation/pages/home_page.dart';

class RpgApp extends StatelessWidget {
  const RpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG App',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
