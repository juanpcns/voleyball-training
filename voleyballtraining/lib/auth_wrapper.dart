// lib/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Necesario para context.watch
import 'package:firebase_auth/firebase_auth.dart' show User; // Solo importamos User
import 'Views/auth_view.dart'; // Importa la interfaz del repositorio de autenticación

// --- Importa tus vistas ---
// Asegúrate que las rutas sean correctas según tu estructura de carpetas ('views/')
import 'Views/home_view.dart'; // La vista principal cuando el usuario está logueado
// --- Fin Imports ---

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch<User?>() para escuchar los cambios del StreamProvider
    // que configuramos en main.dart. Cada vez que el estado de auth cambie,
    // este widget se reconstruirá.
    final firebaseUser = context.watch<User?>();

    // Lógica de decisión:
    if (firebaseUser != null) {
      // Si firebaseUser NO es null, significa que hay un usuario logueado.
      // Navegamos a la pantalla principal de la aplicación.
      // **TODO:** Debes crear e implementar tu HomeView.
      return const HomeView();
    } else {
      // Si firebaseUser ES null, significa que no hay usuario logueado.
      // Navegamos a la pantalla de autenticación (Login/Registro).
      // **TODO:** Debes crear e implementar tu AuthView.
      return const AuthView();
    }
  }
}