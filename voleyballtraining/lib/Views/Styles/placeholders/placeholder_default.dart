import 'package:flutter/material.dart';
import '../tipography/text_styles.dart';

class PlaceholderDefault extends StatelessWidget {
  final String title;
  final Widget child;
  final double height; // Parámetro para la altura
  final double width;  // Parámetro para el ancho

  // Constructor con valores por defecto para `height` y `width`
  const PlaceholderDefault({
    super.key,
    required this.title,
    required this.child,
    this.height = 60, // Valor por defecto de la altura
    this.width = double.infinity, // Valor por defecto del ancho
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.title(isSubtitle: true),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: width, // Usamos el valor de `width`
          height: height, // Usamos el valor de `height`
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF007BFF),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF007BFF),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

