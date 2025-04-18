// lib/Views/Styles/tipography/text_styles.dart
import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

/// Define los estilos de texto reutilizables para la aplicación.
/// Utiliza la fuente 'Poppins' y los colores definidos en [AppColors].
class CustomTextStyles {
  static const String _fontFamily = 'Poppins';

  /// Estilo H1: Título principal (ej. nombre de pantalla)
  /// FontSize: 28, FontWeight: w600 (Semibold), Color: textDark
  static const TextStyle h1 = TextStyle( // <-- Base puede ser const
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // Semibold
    fontSize: 28,
    color: AppColors.textDark,
  );

  /// Estilo H1 Blanco: Título principal sobre fondos oscuros.
  static final TextStyle h1White = h1.copyWith(color: AppColors.textLight); // <-- Cambiado a final

  /// Estilo H2: Subtítulo principal (ej. sección importante)
  /// FontSize: 24, FontWeight: w600 (Semibold), Color: textDark
  static const TextStyle h2 = TextStyle( // <-- Base puede ser const
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // Semibold
    fontSize: 24,
    color: AppColors.textDark,
  );

  /// Estilo H2 Blanco: Subtítulo sobre fondos oscuros.
   static final TextStyle h2White = h2.copyWith(color: AppColors.textLight); // <-- Cambiado a final

  /// Estilo H3: Título de sección o elemento (ej. Card title)
  /// FontSize: 20, FontWeight: w500 (Medium), Color: textDark
  static const TextStyle h3 = TextStyle( // <-- Base puede ser const
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 20,
    color: AppColors.textDark,
  );

   /// Estilo H3 Blanco: Título de sección sobre fondos oscuros.
  static final TextStyle h3White = h3.copyWith(color: AppColors.textLight); // <-- Cambiado a final

  /// Estilo Body: Texto principal del cuerpo.
  /// FontSize: 16, FontWeight: w400 (Regular), Color: textDark
  static const TextStyle body = TextStyle( // <-- Base puede ser const
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    color: AppColors.textDark,
  );

  /// Estilo Body Blanco: Texto principal sobre fondos oscuros.
  static final TextStyle bodyWhite = body.copyWith(color: AppColors.textLight); // <-- Cambiado a final

  /// Estilo Body Gris: Texto secundario o menos enfatizado.
  static final TextStyle bodyGray = body.copyWith(color: AppColors.textGray); // <-- Cambiado a final

  /// Estilo Caption: Texto pequeño (ej. metadatos, notas al pie).
  /// FontSize: 12, FontWeight: w300 (Light), Color: textGray
  static const TextStyle caption = TextStyle( // <-- Base puede ser const
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w300, // Light
    fontSize: 12,
    color: AppColors.textGray,
  );

  /// Estilo Caption Blanco: Texto pequeño sobre fondos oscuros.
  static final TextStyle captionWhite = caption.copyWith(color: AppColors.textLight); // <-- Cambiado a final

  /// Estilo para texto de botones (ej. ElevatedButton)
  /// FontSize: 16, FontWeight: w500 (Medium), Color: textLight (generalmente)
   static const TextStyle button = TextStyle( // <-- Base puede ser const
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 16,
    color: AppColors.textLight, // Color por defecto para botones primarios
  );

  // Asegúrate de que esta clase no pueda ser instanciada
  CustomTextStyles._();
}