import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/chats/chats_list_view.dart';
import '../../providers/auth_provider.dart';
import '../plans/training_plans_view.dart';
import '../profile/user_profile_view.dart';
import '../users/user_list_view.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';

// IMPORTA LA NUEVA VISTA DE ESTADÍSTICAS
import '../stats/stats_view_selector.dart';

class MainMenuView extends StatelessWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUserModel;

    return HomeViewTemplate(
      title: '',
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo y Bienvenida
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              'assets/images/Logo-icon.png',
                              height: 60,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bienvenido',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.secondary, width: 1.4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.30),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Text(
                              'Explora las opciones de tu cuenta',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Panel principal
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 22,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              'Tu Panel',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            GridView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: 1.10,
                              ),
                              children: [
                                _PanelButton(
                                  icon: Icons.account_circle,
                                  label: 'Perfil',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserProfileView(userProfile: user!),
                                    ),
                                  ),
                                ),
                                _PanelButton(
                                  icon: Icons.assignment,
                                  label: 'Planes',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrainingPlansView(userModel: user!),
                                    ),
                                  ),
                                ),
                                _PanelButton(
                                  icon: Icons.chat_rounded,
                                  label: 'Chats',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ChatsListView(),
                                      ),
                                    );
                                  },
                                ),
                                _PanelButton(
                                  icon: Icons.bar_chart_rounded,
                                  label: 'Estadísticas',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StatsViewSelector(userModel: user!),
                                      ),
                                    );
                                  },
                                ),
                                // Solo para entrenadores: Ver Usuarios
                                if (user!.role == 'Entrenador')
                                  _PanelButton(
                                    icon: Icons.group,
                                    label: 'Ver Usuarios',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UserListView(userModel: user),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de cerrar sesión con sombra roja
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 18,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.80),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 34, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onPressed: () async {
                            await Provider.of<AuthProvider>(context, listen: false)
                                .signOutUser();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          },
                          child: const Text('Cerrar Sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _PanelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PanelButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: AppColors.primary.withOpacity(0.18),
        highlightColor: AppColors.primary.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.24), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 46, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
