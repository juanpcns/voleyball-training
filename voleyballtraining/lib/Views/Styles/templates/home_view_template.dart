// lib/Views/Styles/templates/home_view_template.dart
import 'package:flutter/material.dart';
// --- > Importaciones Corregidas (Usando rutas de paquete) <---
// Ya no importamos AppColors aquí si el fondo es siempre la imagen
// import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
// Ya no importamos TextStyles si el AppBar usa el tema
// import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';

/// Una plantilla base para las vistas principales de la aplicación.
///
/// Proporciona un [Scaffold] transparente superpuesto a una imagen de fondo,
/// con un [AppBar] también transparente (estilizado por el tema).
class HomeViewTemplate extends StatelessWidget {
  /// El título que se mostrará en el AppBar.
  final String title;

  /// El contenido principal de la pantalla.
  final Widget body;

  /// Acciones opcionales para el AppBar (ej. botones de íconos).
  final List<Widget>? actions;

  /// Un FloatingActionButton opcional.
  final Widget? floatingActionButton;

  /// Un Drawer (menú lateral) opcional.
  final Widget? drawer;

  /// Permite sobrescribir el AppBar por completo si se necesita uno muy personalizado.
  final PreferredSizeWidget? appBar;

  /// La ruta a la imagen de fondo. Por defecto usa 'assets/images/fondo.png'.
  final String backgroundImagePath;

  const HomeViewTemplate({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.appBar,
    this.backgroundImagePath = 'assets/images/fondo.png', // <-- Ruta por defecto
  });

  @override
  Widget build(BuildContext context) {
    // Ya no necesitamos obtener el color de fondo aquí

    // Obtiene el tema actual para aplicar estilos por defecto
    final theme = Theme.of(context);
    // final appBarTheme = theme.appBarTheme; // No necesitamos obtenerlo explícitamente

    return Stack( // <--- Usamos Stack para superponer capas
      children: [
        // --- Capa 1: Imagen de Fondo ---
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImagePath), // <-- Usa la imagen de fondo
              fit: BoxFit.cover, // Ajusta para cubrir toda la pantalla
            ),
          ),
        ),

        // --- Capa 2: Scaffold Transparente con el Contenido ---
        Scaffold(
          backgroundColor: Colors.transparent, // <-- Scaffold transparente
          // Usa el AppBar personalizado si se proporciona, sino crea uno estándar transparente
          appBar: appBar ?? AppBar(
            title: Text(title), // El estilo viene del tema
            // --- > AppBar transparente para ver el fondo <---
            backgroundColor: Colors.transparent,
            elevation: 0, // Sin sombra para que no oculte la imagen
            actions: actions,
          ),
          drawer: drawer,
          body: body, // El contenido principal se mostrará sobre la imagen
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}