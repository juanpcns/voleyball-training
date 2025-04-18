// lib/Views/Styles/colors/app_colors.dart
import 'package:flutter/material.dart';

/// Define la paleta de colores principal de la aplicación.
/// Usar estas constantes asegura consistencia visual y facilita
/// la actualización de los colores en el futuro.
class AppColors {
  // --- Colores Primarios ---
  /// Color primario principal (ej. azul) - Usaremos tu Naranja
  static const Color primary = Color(0xFFFF8C00); // Naranja principal (de tu código)
  /// Variante más clara del primario (ajustar si es necesario)
  static const Color primaryLight = Color(0xFFFFBD45);
  /// Variante más oscura del primario (ajustar si es necesario)
  static const Color primaryDark = Color(0xFFC55D00);

  // --- Colores Secundarios / Acento ---
  /// Color secundario o de acento (ej. azul) - Usaremos tu Azul
  static const Color secondary = Color(0xFF007BFF); // Azul secundario (de tu código)
   /// Variante más clara del secundario (ajustar si es necesario)
  static const Color secondaryLight = Color(0xFF69A7FF);
   /// Variante más oscura del secundario (ajustar si es necesario)
  static const Color secondaryDark = Color(0xFF0050CB);

  // --- Colores de Texto ---
  /// Color principal para texto oscuro (sobre fondos claros)
  static const Color textDark = Color(0xFF212121); // Casi negro
  /// Color principal para texto claro (sobre fondos oscuros) - ¡IMPORTANTE PARA TEMA OSCURO!
  static const Color textLight = Color(0xFFFAFAFA); // Blanco ligeramente grisáceo (mejor que blanco puro)
  /// Color secundario para texto (gris) - Ajustar para tema oscuro
  static const Color textGray = Color(0xFFBDBDBD); // Un gris más claro para buena visibilidad en oscuro
  /// Color de texto para estados deshabilitados
  static const Color textDisabled = Color(0xFF757575); // Gris medio/oscuro para deshabilitado en oscuro

  // --- Colores de Fondo (Tema Claro) ---
  /// Color de fondo principal para Scaffolds y superficies base (TEMA CLARO)
  static const Color backgroundLight = Color(0xFFFAFAFA);
  /// Color para superficies elevadas como Cards o Dialogs (TEMA CLARO)
  static const Color surfaceLight = Color(0xFFFFFFFF); // Blanco puro

  // --- Colores de Fondo (Tema Oscuro) ---
  /// Color de fondo principal para Scaffolds (TEMA OSCURO)
  static const Color backgroundDark = Color(0xFF121212); // Negro estándar Material Dark
  /// Color para superficies elevadas como Cards o Dialogs (TEMA OSCURO)
  static const Color surfaceDark = Color(0xFF1E1E1E); // Un gris muy oscuro, ligeramente más claro que el fondo

  // --- Colores Semánticos ---
  /// Color para indicar errores (Claro)
  static const Color errorLight = Color(0xFFD32F2F); // Rojo oscuro
  /// Color para indicar errores (Oscuro) - Más brillante para visibilidad
  static const Color errorDark = Color(0xFFCF6679); // Rojo Material Dark Error
  /// Color para indicar éxito (Claro)
  static const Color success = Color(0xFF388E3C); // Verde
   /// Color para indicar éxito (Oscuro) - Ajustar si se necesita más brillo
  static const Color successDark = Color(0xFF66BB6A); // Un verde más brillante
  /// Color para indicar advertencias (Claro)
  static const Color warning = Color(0xFFFFA000); // Ámbar
  /// Color para indicar advertencias (Oscuro) - Ajustar si se necesita más brillo
  static const Color warningDark = Color(0xFFFFCA28); // Ámbar más brillante

  // --- Otros ---
  /// Color para divisores o bordes sutiles (Ajustar para tema oscuro)
  static const Color divider = Color(0xFF424242); // Un gris oscuro para divisores en tema dark
   /// Color para elementos deshabilitados (fondo) (Ajustar para tema oscuro)
  static const Color disabled = Color(0xFF424242); // Gris oscuro para fondos deshabilitados

  // Asegúrate de que esta clase no pueda ser instanciada
  AppColors._();
}