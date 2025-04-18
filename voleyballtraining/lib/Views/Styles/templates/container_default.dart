// lib/Views/Styles/templates/container_default.dart
import 'package:flutter/material.dart';
// Asegúrate que la ruta de importación sea correcta
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart'; // Necesitamos AppColors.primary

/// Un widget [Container] reutilizable con estilo predeterminado para el tema oscuro.
///
/// Aplica padding al contenido, margen externo, bordes redondeados.
/// SIEMPRE incluye la imagen 'hinata_container_default.png' como fondo,
/// cubierta por una capa negra semi-transparente.
/// SIEMPRE tiene un borde naranja y una sombra/resplandor naranja EXTERIOR.
class ContainerDefault extends StatelessWidget {
  /// El widget hijo que se mostrará dentro del contenedor.
  final Widget child;

  /// El padding aplicado AL CONTENIDO (child) dentro del contenedor.
  final EdgeInsetsGeometry padding;

  /// El margen externo del contenedor.
  final EdgeInsetsGeometry margin;

  /// El radio de los bordes redondeados (aplica al contenedor y corta el contenido).
  final double borderRadius;

  // --- Parámetros de Imagen y Overlay ---
  /// Cómo debe ajustarse la imagen de Hinata dentro del contenedor.
  final BoxFit? hinataImageFit;
  /// Opacidad de la capa negra sobre la imagen (0.0 = transparente, 1.0 = opaco).
  final double overlayOpacity;
  // --- Fin Parámetros Imagen y Overlay ---

  // --- Constructor Simplificado ---
  const ContainerDefault({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.borderRadius = 12.0,
    this.hinataImageFit = BoxFit.cover,
    this.overlayOpacity = 0.5,
  });
  // --- Fin Constructor ---

  @override
  Widget build(BuildContext context) {
    // Validar opacidad
    final double validOpacity = overlayOpacity.clamp(0.0, 1.0);

    return Container( // Contenedor exterior para margen, forma, borde, sombra, clip
      clipBehavior: Clip.antiAlias,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),

        // --- > BORDE NARANJA FIJO <---
        border: Border.all(
          color: AppColors.primary, // Color Naranja Primario
          width: 1.5,             // Ancho del borde
        ),
        // --- > SOMBRA/RESPLANDOR NARANJA EXTERIOR <---
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1), // Naranja con opacidad (ajustada)
             // --- > Ajustes para efecto exterior <---
            blurRadius: 10.0,        // Reducimos un poco el blur
            spreadRadius: 20.0,       // AUMENTAMOS el spread para empujar hacia afuera
            offset: Offset.zero,   // Sombra centrada
          ),
        ],
      ),
      // El hijo del contenedor exterior es el Stack con las capas de fondo y contenido
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // --- Capa 1: Imagen de Hinata ---
          Positioned.fill(
            child: Image.asset(
              'assets/images/hinata_container_default.png',
              fit: hinataImageFit,
            ),
          ),
          // --- Capa 2: Overlay Negro Semi-Transparente ---
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(validOpacity),
            ),
          ),
          // --- Capa 3: Contenido Original (Child) con Padding ---
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}