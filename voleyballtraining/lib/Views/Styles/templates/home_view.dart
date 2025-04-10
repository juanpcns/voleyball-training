import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo negro de toda la pantalla
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagen encima del fondo negro
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
