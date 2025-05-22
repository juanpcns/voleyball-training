import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'views/auth_view.dart';
import 'views/menu/main_menu_view.dart'; // <--- Corrige el import aquí

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print("--- Construyendo AuthWrapper ---");

    final firebaseUser = context.watch<User?>();
    print("--- AuthWrapper: Valor de firebaseUser: ${firebaseUser?.uid ?? 'null'} ---");

    if (firebaseUser != null) {
      print("--- AuthWrapper: Usuario NO es null. Devolviendo MainMenuView. ---");
      return const MainMenuView(); // <--- Cambiado aquí
    } else {
      print("--- AuthWrapper: Usuario ES null. Devolviendo AuthView. ---");
      return const AuthView();
    }
  }
}
