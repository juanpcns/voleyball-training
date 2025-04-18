// lib/Views/Styles/placeholders/placeholder_default.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // <--- ¡ASEGÚRATE DE TENER ESTA LÍNEA!
import '../colors/app_colors.dart';   // <-- Importa colores

/// Un widget placeholder reutilizable con una animación shimmer.
///
/// Útil para mostrar mientras se carga contenido asíncrono.
/// Usa colores base definidos en [AppColors].
class PlaceholderDefault extends StatelessWidget {
  /// Ancho del placeholder.
  final double width;
  /// Alto del placeholder.
  final double height;
  /// Forma del placeholder (bordes redondeados).
  final BoxShape shape;
  /// Radio del borde si la forma es rectangular.
  final double borderRadius;
  /// Margen exterior.
  final EdgeInsetsGeometry margin;

  const PlaceholderDefault({
    super.key,
    this.width = double.infinity, // Ocupa todo el ancho por defecto
    this.height = 100.0,         // Altura por defecto
    this.shape = BoxShape.rectangle,
    this.borderRadius = 8.0,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0), // Usa const
  });

  /// Constructor para un placeholder circular (ej. para avatares).
  const PlaceholderDefault.circle({
    super.key,
    required double radius,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Usa const
  })  : width = radius * 2,
        height = radius * 2,
        shape = BoxShape.circle,
        borderRadius = 0; // No aplica para círculo


  /// Constructor para una línea de texto placeholder.
  const PlaceholderDefault.line({
    super.key,
    this.width = double.infinity,
    this.height = 16.0, // Altura típica de una línea de texto
    this.margin = const EdgeInsets.symmetric(vertical: 4.0), // Usa const
    this.borderRadius = 4.0, // Bordes más suaves para líneas
  }) : shape = BoxShape.rectangle;


  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors( // <-- Aquí se usa Shimmer
      baseColor: AppColors.disabled.withOpacity(0.5), // <-- Color base desde AppColors
      highlightColor: AppColors.disabled.withOpacity(0.2), // <-- Color de brillo desde AppColors
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.disabled, // <-- Color principal del contenedor
          shape: shape,
          // Aplica borderRadius solo si la forma es rectangular
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius) // Usa const si es posible
              : null,
        ),
      ),
    );
  }
}