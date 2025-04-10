import 'package:flutter/material.dart';
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
          const HomeView(), // Fondo
          ContainerDefault(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 👈 Centrado vertical
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagen
                    Image.asset(
                      'assets/images/Logo-icon.png',
                      height: 140,
                    ),
                    const SizedBox(height: 40),

                    // Título
                    Text(
                      '¡Bienvenido!',
                      style: TextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Texto descriptivo
                    Text(
                      'Eleva tu juego con entrenamientos avanzados y análisis en tiempo real.',
                      style: TextStyles.defaultText,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),

                    // Botón
                    ButtonDefault(
                      text: 'Empezar',
                      onPressed: () {},
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
