import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'coach_players_list_view.dart';
import 'player_stats_view.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';

class StatsViewSelector extends StatelessWidget {
  final UserModel userModel;

  const StatsViewSelector({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUserModel;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: false,
      ),
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo.png',
              fit: BoxFit.cover,
            ),
          ),
          // Sombra para mejorar legibilidad
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.67),
            ),
          ),
          // Contenido
          user == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.only(
                    left: 12, right: 12, top: kToolbarHeight + 18, bottom: 16,
                  ),
                  child: user.role == 'Entrenador'
                      ? const CoachPlayersListView()
                      : PlayerStatsView(
                          playerId: user.userId,
                          playerName: user.fullName,
                        ),
                ),
        ],
      ),
    );
  }
}
