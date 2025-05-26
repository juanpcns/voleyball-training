import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'coach_players_list_view.dart';
import 'player_stats_view.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';

class StatsViewSelector extends StatelessWidget {
  final UserModel userModel;

  const StatsViewSelector({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUserModel;

    return HomeViewTemplate(
      title: 'Estadísticas',
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // Aquí NO oscurecemos el fondo
          // Si quieres agregar color semitransparente para legibilidad, ajusta aquí, sino déjalo transparente
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : user.role == 'Entrenador'
                ? const CoachPlayersListView()
                : PlayerStatsView(
                    playerId: user.userId,
                    playerName: user.fullName,
                    isCoach: false,
                  ),
      ),
      // Si quieres agregar floatingActionButton condicional aquí, puedes
      floatingActionButton: null,
    );
  }
}
