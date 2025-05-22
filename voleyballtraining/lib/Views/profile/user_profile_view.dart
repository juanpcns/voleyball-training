import 'package:flutter/material.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import '../../models/user_model.dart'; // Ajusta la ruta si es necesario

// Fondo global
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';
// Para la tarjeta del perfil
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';

class UserProfileView extends StatelessWidget {
  final UserModel userProfile;

  const UserProfileView({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return HomeViewTemplate(
      title: 'Mi Perfil',
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.95,
          child: ContainerDefault(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido vertical
                crossAxisAlignment: CrossAxisAlignment.start, // Alinear info a la izq.
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/Logo-icon.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Mi Perfil',
                      style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildProfileInfoRow('Nombre:', userProfile.fullName, context),
                  _buildProfileInfoRow('Email:', userProfile.email, context),
                  _buildProfileInfoRow('Rol:', userProfile.role, context),
                  _buildProfileInfoRow(
                    'Miembro desde:',
                    userProfile.createdAt.toDate().toLocal().toString().split(' ')[0],
                    context,
                  ),
                  if (userProfile.idNumber != null && userProfile.idNumber!.isNotEmpty)
                    _buildProfileInfoRow('Cédula:', userProfile.idNumber!, context),
                  if (userProfile.phoneNumber != null && userProfile.phoneNumber!.isNotEmpty)
                    _buildProfileInfoRow('Teléfono:', userProfile.phoneNumber!, context),
                  if (userProfile.dateOfBirth != null)
                    _buildProfileInfoRow(
                      'Fecha Nacimiento:',
                      userProfile.dateOfBirth!.toDate().toLocal().toString().split(' ')[0],
                      context,
                    ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      style: CustomButtonStyles.primary(),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('TODO: Navegar a Editar Perfil')),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar Perfil'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
