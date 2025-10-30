import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../models/plan_assignment_model.dart';
import '../../repositories/plan_assignment_repository_base.dart';

class UserDetailView extends StatelessWidget {
  final UserModel user;

  const UserDetailView({super.key, required this.user});

  String _formatearFecha(DateTime fecha) {
    return "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }

  /// Convierte el enum a un string amigable
  String estadoToString(PlanAssignmentStatus estado) {
    switch (estado) {
      case PlanAssignmentStatus.aceptado:
        return 'Aceptado';
      case PlanAssignmentStatus.completado:
        return 'Completado';
      case PlanAssignmentStatus.pendiente:
        return 'Pendiente';
      case PlanAssignmentStatus.rechazado:
        return 'Rechazado';
      default:
        return 'Otro';
    }
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
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 30,
                    child: Icon(Icons.sports_volleyball, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  // Título
                  Text(
                    titulo,
                    style: CustomTextStyles.h2White.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  // Datos básicos
                  _dato("Nombre", user.fullName),
                  _dato("Email", user.email),
                  _dato("Rol", user.role),
                  _dato("Miembro desde", _formatearFecha(user.createdAt.toDate())),
                  const SizedBox(height: 20),

                  // ---- ESTADÍSTICAS DE PLANES POR ESTADO ----
                  StreamBuilder<List<PlanAssignment>>(
                    stream: Provider.of<PlanAssignmentRepositoryBase>(context, listen: false)
                        .getAssignmentsForPlayer(user.userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const Text("Error al cargar planes", style: TextStyle(color: Colors.red));
                      }
                      final assignments = snapshot.data ?? [];

                      // Contar por estado usando el nombre amigable
                      final Map<String, int> counts = {
                        'Aceptado': 0,
                        'Rechazado': 0,
                        'Completado': 0,
                        'Pendiente': 0,
                      };
                      for (final assignment in assignments) {
                        final estado = estadoToString(assignment.status);
                        if (counts.containsKey(estado)) {
                          counts[estado] = counts[estado]! + 1;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 24, thickness: 1),
                          Text("Planes asignados:", style: CustomTextStyles.bodyWhite.copyWith(fontWeight: FontWeight.bold)),
                          _datoEstado("Aceptados", counts['Aceptado'] ?? 0, AppColors.successDark),
                          _datoEstado("Completados", counts['Completado'] ?? 0, AppColors.secondary),
                          _datoEstado("Pendientes", counts['Pendiente'] ?? 0, AppColors.warningDark),
                          _datoEstado("Rechazados", counts['Rechazado'] ?? 0, AppColors.errorDark),
                        ],
                      );
                    },
                  ),
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

  Widget _datoEstado(String label, int cantidad, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: CustomTextStyles.bodyWhite.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            "$cantidad",
            style: CustomTextStyles.bodyWhite,
          ),
        ],
      ),
    );
  }
}
