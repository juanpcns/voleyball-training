// lib/Views/Styles/templates/home_view_template.dart
import 'package:flutter/material.dart';
// --- > Importaciones Corregidas (Usando rutas de paquete) <---
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';

/// Una plantilla base para las vistas principales de la aplicación.
///
/// Proporciona un [Scaffold] con un [AppBar] estilizado (tomado del tema)
/// y un fondo [AppColors.backgroundDark] por defecto para el tema oscuro.
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

  /// Permite sobrescribir el color de fondo si es necesario.
  final Color? backgroundColor;

  /// Permite sobrescribir el AppBar por completo si se necesita uno muy personalizado.
  final PreferredSizeWidget? appBar;

  const HomeViewTemplate({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.backgroundColor,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    // Determina el color de fondo a usar
    final Color effectiveBackgroundColor = backgroundColor ?? AppColors.backgroundDark; // <-- Usa backgroundDark

    // Obtiene el tema actual para aplicar estilos por defecto
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme; // Tema del AppBar definido en main.dart

    return Scaffold(
      backgroundColor: effectiveBackgroundColor, // <-- Fondo oscuro desde AppColors
      // Usa el AppBar personalizado si se proporciona, sino crea uno estándar basado en el tema
      appBar: appBar ?? AppBar(
        // El estilo del título se toma del tema si no se especifica aquí
        // titleTextStyle: appBarTheme.titleTextStyle, // Ya aplicado por el tema
        title: Text(title), // El estilo (h3White) lo aplica AppBarTheme

        // El color de fondo, foregroundColor y elevation vienen del AppBarTheme
        // backgroundColor: appBarTheme.backgroundColor, // Ya aplicado por el tema
        // foregroundColor: appBarTheme.foregroundColor, // Ya aplicado por el tema
        // elevation: appBarTheme.elevation, // <-- Removido 4.0 para usar el del tema (0.0)

        actions: actions,
        // iconTheme y actionsIconTheme también vienen del tema
      ),
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}