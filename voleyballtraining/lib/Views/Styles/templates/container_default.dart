import 'package:flutter/material.dart';

class ContainerDefault extends StatelessWidget {
  final Widget? child;

  const ContainerDefault({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: size.width * 0.85,
        height: size.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/hinata_container_default.png'),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(30, 30, 30, 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFF007BFF),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8C00).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Parte superior (80%) sin color
              Expanded(
                flex: 15,
                child: SizedBox(
                  width: double.infinity,
                  // Contenedor sin color, puedes usar child aquí
                  child: child,
                ),
              ),

              // Parte inferior (20%) - Texto de derechos
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      '© 2025 Voleibol Trainer',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
