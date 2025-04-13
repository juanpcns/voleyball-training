import 'package:flutter/material.dart';
import 'Styles/templates/container_default.dart';
import 'Styles/templates/home_view.dart';
import 'Styles/tipography/text_styles.dart';
import 'Styles/buttons/button_styles.dart';
import 'create_user.dart';

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeView(), // Fondo
        ContainerDefault(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    style: TextStyles.title(), // Por defecto es modo título
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Texto descriptivo
                  Text(
                    'Eleva tu juego con entrenamientos avanzados y análisis en tiempo real.',
                    style: TextStyles.defaultText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50), // Espacio con el botón

                  // Botón
                  ButtonDefault(
                    text: 'Empezar',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateUser(),
                        ),
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 20,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
