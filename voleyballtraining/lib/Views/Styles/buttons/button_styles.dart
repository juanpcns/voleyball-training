import 'package:flutter/material.dart';
import '../tipography/text_styles.dart';

class ButtonDefault extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding; // 👈 Nuevo parámetro

  const ButtonDefault({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 20), // 👈 Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFFF8C00); // Naranja
    const backgroundColor = Color.fromRGBO(30, 30, 30, 0.9);
    const pressedColor = Color(0xFFFF8C00); // Cambiará cuando se presione

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return pressedColor;
            }
            return backgroundColor;
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(color: Colors.white, width: 2);
            }
            return const BorderSide(color: borderColor, width: 2);
          },
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding), // 👈 Aquí se usa el padding
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevation: WidgetStateProperty.all(4),
      ),
      child: Text(
        text,
        style: TextStyles.button,
      ),
    );
  }
}
