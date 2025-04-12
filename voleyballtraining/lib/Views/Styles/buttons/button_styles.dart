import 'package:flutter/material.dart';
import '../tipography/text_styles.dart';

class ButtonDefault extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  final Widget? navigateTo; // 👈 Nuevo parámetro opcional
  final VoidCallback? onPressed;

  const ButtonDefault({
    super.key,
    required this.text,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    this.navigateTo,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFFF8C00);
    const backgroundColor = Color.fromRGBO(30, 30, 30, 0.9);
    const pressedColor = Color(0xFFFF8C00);

    return ElevatedButton(
      onPressed: () {
        if (navigateTo != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => navigateTo!),
          );
        } else if (onPressed != null) {
          onPressed!();
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.pressed)
              ? pressedColor
              : backgroundColor,
        ),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (states) => BorderSide(
            color: states.contains(WidgetState.pressed) ? Colors.white : borderColor,
            width: 2,
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding),
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