import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';

class UserDetailView extends StatelessWidget {
  final UserModel user;

  const UserDetailView({super.key, required this.user});

  String _formatearFecha(DateTime fecha) {
    return "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context, listen: false);
    final bool esMismoUsuario = currentUser?.uid == user.userId;

    final String titulo = esMismoUsuario ? 'Mi Perfil' : 'Perfil de ${user.fullName}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(titulo, style: CustomTextStyles.h3White),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo con imagen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono redondo
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 30,
                    child: const Icon(Icons.sports_volleyball, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  // Título
                  Text(
                    titulo,
                    style: CustomTextStyles.h2White.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  // Datos
                  _dato("Nombre", user.fullName),
                  _dato("Email", user.email),
                  _dato("Rol", user.role),
                  _dato("Miembro desde", _formatearFecha(user.createdAt.toDate())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: CustomTextStyles.bodyWhite.copyWith(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: valor,
              style: CustomTextStyles.bodyWhite,
            ),
          ],
        ),
      ),
    );
  }
}
