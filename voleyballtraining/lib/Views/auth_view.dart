// lib/views/auth_view.dart
import 'package:flutter/material.dart';
import 'create_user.dart'; // Asumiendo que renombraste tu archivo CreateUser
// O importa directamente tu widget si el archivo se llama diferente
// import 'package:voleyballtraining/widgets_o_views/CreateUser.dart'; // Ajusta la ruta

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    // Por ahora, simplemente muestra la vista de Crear Usuario.
    // Más adelante podrías añadir aquí un selector para ir a Login.
    // return CreateUser(); // Si el archivo se llama create_user.dart

    // Es buena práctica que los nombres de archivo sean snake_case (minúsculas con guión bajo)
    // y las clases UpperCamelCase. Si tu archivo se llama CreateUser.dart:
     return CreateUser(); // Usa el nombre de tu clase/widget
  }
}