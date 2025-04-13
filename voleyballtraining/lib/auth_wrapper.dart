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
    print("--- Construyendo AuthWrapper ---"); // <-- ¿Aparece después del login?

    final firebaseUser = context.watch<User?>();
    // <-- ¿Qué valor tiene firebaseUser DESPUÉS del login exitoso?
    print("--- AuthWrapper: Valor de firebaseUser: ${firebaseUser?.uid ?? 'null'} ---");

    if (firebaseUser != null) {
      // <-- ¿Entra aquí después del login exitoso?
      print("--- AuthWrapper: Usuario NO es null. Devolviendo HomeView. ---");
      return const HomeView();
    } else {
      // <-- ¿O sigue entrando aquí?
      print("--- AuthWrapper: Usuario ES null. Devolviendo AuthView. ---");
      return const AuthView();
    }
  }
}