import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_view.dart';

class SelectUserForChatView extends StatelessWidget {
  final UserModel currentUser;

  const SelectUserForChatView({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Lógica: Si soy 'Jugador', veo solo entrenadores. Si soy 'Entrenador', veo solo jugadores.
    final String targetRole = currentUser.role == 'Jugador' ? 'Entrenador' : 'Jugador';
    final List<UserModel> availableUsers = userProvider.users
        .where((u) =>
            u.role == targetRole &&
            u.userId != currentUser.userId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona un usuario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableUsers.isEmpty
              ? const Center(child: Text('No hay usuarios disponibles para chatear.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: availableUsers.length,
                  itemBuilder: (context, index) {
                    final user = availableUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?'),
                        ),
                        title: Text(user.fullName),
                        subtitle: Text(user.email),
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
                      ),
                    );
                  },
                ),
    );
  }
}
