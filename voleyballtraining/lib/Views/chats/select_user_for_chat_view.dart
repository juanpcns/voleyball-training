// lib/views/chat/select_user_for_chat_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_view.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';

class SelectUserForChatView extends StatelessWidget {
  final UserModel currentUser;

  const SelectUserForChatView({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);

    // Filtrado de usuarios para contacto válido según rol
    final String targetRole = currentUser.role == 'Jugador' ? 'Entrenador' : 'Jugador';
    final List<UserModel> availableUsers = userProvider.users
        .where((u) =>
            u.role == targetRole &&
            u.userId != currentUser.userId)
        .toList();

    return HomeViewTemplate(
      title: "Selecciona un usuario",
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableUsers.isEmpty
              ? Center(
                  child: Text(
                    'No hay usuarios disponibles para chatear.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: availableUsers.length,
                  itemBuilder: (context, index) {
                    final user = availableUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: AppColors.surfaceDark.withOpacity(0.90),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.14),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        // <<<--- AÑADIDO (para TC-003)
                        key: Key('select_chat_user_item_${user.userId}'),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.72),
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.primary.withOpacity(0.75)),
                        onTap: () async {
                          // Obtén o crea el chat
                          final chatId = await Provider.of<ChatProvider>(context, listen: false)
                              .getOrCreateChatId([currentUser.userId, user.userId]);

                          // Navega al chat con ese usuario
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatView(
                                  chatId: chatId,
                                  currentUserId: currentUser.userId,
                                  otherUserName: user.fullName,
                                ),
                              ),
                            );
                          }
                        },
                        splashColor: AppColors.primary.withOpacity(0.10),
                      ),
                    );
                  },
                ),
    );
  }
}