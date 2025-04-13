// lib/auth_wrapper.dart (CON DEBUG PRINTS)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

import 'views/auth_view.dart';
import 'views/home_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print("--- Construyendo AuthWrapper ---"); // <-- AÑADIR

    // Leemos el usuario del StreamProvider
    final firebaseUser = context.watch<User?>();
    print("--- AuthWrapper: Valor de firebaseUser: ${firebaseUser?.uid ?? 'null'} ---"); // <-- AÑADIR

    // Lógica de decisión
    if (firebaseUser != null) {
      print("--- AuthWrapper: Usuario NO es null. Devolviendo HomeView. ---"); // <-- AÑADIR
      // TODO: Asegúrate que HomeView no tenga errores de construcción
      return const HomeView();
    } else {
      print("--- AuthWrapper: Usuario ES null. Devolviendo AuthView. ---"); // <-- AÑADIR
      // TODO: Asegúrate que AuthView no tenga errores de construcción
      return const AuthView();
    }
  }
}