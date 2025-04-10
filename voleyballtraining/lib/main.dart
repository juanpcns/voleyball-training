import 'package:flutter/material.dart';
import 'package:voleyballtraining/Views/Screen/Start_View.dart';
import 'Views/Styles/templates/container_default.dart';
import 'Views/Styles/templates/home_view.dart';
import 'Views/Styles/tipography/text_styles.dart';
import 'Views/Styles/buttons/button_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HomeView(),
          StartView(),
        ],
      ),
    );
  }
}
