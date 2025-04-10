import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle defaultText = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: Colors.white, // #FFFFFF
  );
  
  // Estilo para títulos
  static const TextStyle title = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Color(0xFFFF8C00),
    shadows: [
      Shadow(
        offset: Offset(0, 2.5),       // Sombrado centrado ligeramente hacia abajo
        blurRadius: 10,        // Difuminado más suave
        color: Color(0xFFFF8C00),   // Mismo color del texto
      ),
    ],
  );
    // Estilo para texto de botón
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
