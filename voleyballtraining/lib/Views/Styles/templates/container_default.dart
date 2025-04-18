// lib/Views/Styles/templates/container_default.dart
import 'package:flutter/material.dart';
// Asegúrate que la ruta de importación sea correcta
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';

/// Un widget [Container] reutilizable con estilo predeterminado para el tema oscuro.
///
/// Aplica padding, margen, color de fondo ([AppColors.surfaceDark]),
/// bordes redondeados y opcionalmente un borde sutil o una sombra.
/// Ideal para crear 'cards' o secciones visualmente separadas en modo oscuro.
class ContainerDefault extends StatelessWidget {
  /// El widget hijo que se mostrará dentro del contenedor.
  final Widget child;

  /// El padding interno del contenedor. Por defecto es 16.0 en todas las direcciones.
  final EdgeInsetsGeometry padding;

  /// El margen externo del contenedor. Por defecto es horizontal 12.0 y vertical 8.0.
  final EdgeInsetsGeometry margin;

  /// El radio de los bordes redondeados. Por defecto es 12.0.
  final double borderRadius;

  /// Si se debe mostrar una sombra sutil (menos común en tema oscuro). Por defecto es false.
  final bool showShadow;

  /// Si se debe mostrar un borde sutil (más común en tema oscuro para separar). Por defecto es true.
  final bool showBorder;

  /// Color del borde si [showBorder] es true. Por defecto es [AppColors.divider].
  final Color borderColor;

  /// Ancho del borde si [showBorder] es true. Por defecto es 0.5.
  final double borderWidth;

  /// Color de fondo personalizado (opcional, por defecto usa AppColors.surfaceDark).
  final Color? backgroundColor;

  const ContainerDefault({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0), // Usa const
    this.margin = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Usa const
    this.borderRadius = 12.0,
    this.showShadow = false, // Sombra desactivada por defecto en oscuro
    this.showBorder = true,  // Borde activado por defecto en oscuro
    this.borderColor = AppColors.divider, // Color de divisor oscuro desde AppColors
    this.borderWidth = 0.5, // Borde muy sutil
    this.backgroundColor, // Permite sobrescribir el color de fondo
  });

  @override
  Widget build(BuildContext context) {
    // Determina el color de fondo a usar
    final Color effectiveBackgroundColor = backgroundColor ?? AppColors.surfaceDark;

    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        // Usa el color de fondo efectivo (personalizado o surfaceDark)
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor, // Color del borde desde AppColors
                width: borderWidth,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  // Sombra muy sutil si se activa para modo oscuro
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2), // Sombra más corta
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}