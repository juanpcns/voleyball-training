import 'package:flutter/material.dart';
import 'package:voleyballtraining/Views/Styles/placeholders/placeholder_default.dart';
import '../Styles/templates/container_default.dart';
import '../Styles/templates/home_view.dart';
import '../Styles/tipography/text_styles.dart';
import '../Styles/buttons/button_styles.dart';


class CreateUser extends StatelessWidget {
  const CreateUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HomeView(), // Fondo de pantalla (HomeView)
          ContainerDefault(  // Contenedor con fondo semi-transparente
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/Logo-icon.png',
                    height: 140,
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    'Crear Usuario',
                    style: TextStyles.title(), // Estilo de título
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Primer PlaceholderDefault
                  const PlaceholderDefault(
                    title: 'Correo Electrónico',
                    height: 70,
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Escribe tu correo electrónico',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Segundo PlaceholderDefault
                  const PlaceholderDefault(
                    title: 'Contraseña',
                    height: 70,
                    width: 300,
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu contraseña',
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Espacio entre los placeholders y el botón

                  // Botón para crear el usuario
                  ButtonDefault(
                    text: 'Crear Usuario',
                    onPressed: () {},
                    padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
