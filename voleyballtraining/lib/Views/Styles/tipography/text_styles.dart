import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle defaultText = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: Colors.white,
  );

  // Método para obtener el estilo de título o subtítulo
  static TextStyle title({bool isSubtitle = false}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: isSubtitle ? 11 : 20,
      color: const Color(0xFFFF8C00),
      shadows: const [
        Shadow(
          offset: Offset(0, 2.5),
          blurRadius: 10,
          color: Color(0xFFFF8C00),
        ),
      ],
    );
  }

  // Estilo para texto de botón
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
