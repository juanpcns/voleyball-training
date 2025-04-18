import 'package:flutter/material.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
// --- > Importaciones Corregidas (Usando rutas de paquete) <---// Solo una vez
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
// Importa HomeView si es la pantalla o HomeViewTemplate si es la plantilla
// import 'package:voleyballtraining/Views/home_view.dart'; // O la plantilla
import 'package:voleyballtraining/Views/create_user.dart'; // Asumiendo que está en Views

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceder a los estilos del tema actual (definido en main.dart)
    final textTheme = Theme.of(context).textTheme;

    return Scaffold( // Es mejor usar Scaffold como base si esta es una pantalla completa
      // backgroundColor: Colors.transparent, // Si quieres que se vea el fondo del Stack si pones algo detrás
      body: Stack(
        children: [
          // --- Fondo ---
          // TODO: Reemplaza esto con tu fondo deseado.
          // Si es solo un color/imagen, usa un Container:
          Container(
             decoration: const BoxDecoration(
               // Ejemplo: color de fondo o imagen
                color: AppColors.backgroundDark, // O el color/imagen que uses
              //   image: DecorationImage(
              //     image: AssetImage('assets/images/fondo.png'),
              //     fit: BoxFit.cover,
              //   ),
             ),
           ),
          // --- Contenido Centrado ---
          Center( // Centra el ContainerDefault en la pantalla
            child: ContainerDefault( // Usa el contenedor estilizado
              // Ajusta el margen si es necesario para que no ocupe toda la pantalla
              margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30), // Padding interno
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagen
                    Image.asset(
                      'assets/images/Logo-icon.png', // Asegúrate que la ruta es correcta
                      height: 140,
                    ),
                    const SizedBox(height: 40),

                    // Título - Usando estilo del tema o CustomTextStyles
                    Text(
                      '¡Bienvenido!',
                      // Opción 1: Usar estilo del tema (recomendado)
                      style: textTheme.displaySmall, // ej. displaySmall mapea a h2White
                      // Opción 2: Usar CustomTextStyles directamente
                      // style: CustomTextStyles.h2White,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Texto descriptivo - Usando estilo del tema o CustomTextStyles
                    Text(
                      'Eleva tu juego con entrenamientos avanzados y análisis en tiempo real.',
                       // Opción 1: Usar estilo del tema (recomendado)
                      style: textTheme.bodyMedium, // ej. bodyMedium mapea a bodyWhite
                       // Opción 2: Usar CustomTextStyles directamente
                      // style: CustomTextStyles.bodyWhite,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),

                    // Botón - Usando ElevatedButton estándar y CustomButtonStyles
                    ElevatedButton(
                      // Aplica el estilo primario que definimos
                      style: CustomButtonStyles.primary(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateUser(),
                          ),
                        );
                      },
                      // El padding se define en CustomButtonStyles.primary()
                      // Evita padding excesivo aquí, deja que el estilo lo maneje.
                      // Si necesitas que sea más ancho, considera envolverlo en SizedBox o usar FractionallySizedBox
                      child: const Text('Empezar'),
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