import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'player_stats_view.dart';
import '../../Views/Styles/colors/app_colors.dart';

class CoachPlayersListView extends StatelessWidget {
  const CoachPlayersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final players = userProvider.playerUsers;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.67),
          ),
        ),
        // Contenido
        Scaffold(
          backgroundColor: Colors.transparent,
          body: players.isEmpty
              ? Center(
                  child: Text(
                    'No hay jugadores asignados.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      color: AppColors.surfaceDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: ListTile(
                        leading: const Icon(Icons.account_circle, color: AppColors.primary, size: 38),
                        title: Text(
                          player.fullName,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          player.email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondary, size: 22),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerStatsView(playerId: player.userId, playerName: player.fullName),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
