// lib/views/auth_view.dart
import 'package:flutter/material.dart';
// Importa tus vistas de Login y Crear Usuario
// Asegúrate de que las rutas y los nombres de las clases sean correctos
import 'login_view.dart';
import 'create_user.dart'; // O como hayas llamado al archivo/clase de registro

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  // Variable de estado para controlar qué vista mostrar: Login o Registro
  // true = Mostrar Login, false = Mostrar Registro
  bool _showLoginPage = true; // Empezamos mostrando la página de Login

  // Método para cambiar el estado y alternar la vista
  void _toggleView() {
    // setState() notifica a Flutter que el estado cambió y debe reconstruir el widget
    setState(() {
      _showLoginPage = !_showLoginPage; // Invierte el valor booleano
    });
  }

  @override
  Widget build(BuildContext context) {
    // Decide qué widget construir basado en el estado _showLoginPage
    if (_showLoginPage) {
      // Si debemos mostrar Login, construimos LoginView
      // Le pasamos la función _toggleView al parámetro onGoToRegister
      // para que el botón "Regístrate" dentro de LoginView pueda llamar a esta función.
      return LoginView(onGoToRegister: _toggleView);
    } else {
      // Si debemos mostrar Registro, construimos CreateUser
      // Le pasamos la función _toggleView a un parámetro onGoToLogin
      // (que debemos añadir en CreateUser) para que el botón "Inicia Sesión"
      // dentro de CreateUser pueda llamar a esta función.
      return CreateUser(onGoToLogin: _toggleView);
    }
  }
}