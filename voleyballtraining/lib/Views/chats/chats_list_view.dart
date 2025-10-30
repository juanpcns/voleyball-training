import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import 'chat_view.dart';
import 'select_user_for_chat_view.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';

class ChatsListView extends StatefulWidget {
  const ChatsListView({super.key});

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUserModel;
    if (currentUser != null) {
      Provider.of<ChatProvider>(context, listen: false).loadUserChats(currentUser.userId);
    }
    // Cargar los usuarios una sola vez (si no está ya cargado)
    Provider.of<UserProvider>(context, listen: false).loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = Provider.of<AuthProvider>(context).currentUserModel;

    return HomeViewTemplate(
      title: 'Tus Chats',
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.black.withOpacity(0.25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: chatProvider.userChats.isEmpty
            ? Center(
                child: Text(
                  'No tienes chats aún.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              )
            : ListView.separated(
                itemCount: chatProvider.userChats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final chat = chatProvider.userChats[index];
                  final otherUserId = chat.participantIds.firstWhere((id) => id != currentUser?.userId);

                  // Buscar el nombre real del usuario
                  final otherUser = userProvider.users.firstWhere(
                    (u) => u.userId == otherUserId,
                    orElse: () => UserModel(
                      userId: otherUserId,
                      email: '',
                      fullName: 'Usuario',
                      role: '',
                      createdAt: Timestamp.fromDate(DateTime.now()),
                      dateOfBirth: null,
                      phoneNumber: null,
                      idNumber: null,
                    ),
                  );

                  final displayName = otherUser.fullName.isNotEmpty ? otherUser.fullName : otherUserId;

                  return Card(
                    elevation: 4,
                    color: AppColors.surfaceDark.withOpacity(0.80),
                    shadowColor: AppColors.primary.withOpacity(0.16),
                    margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    child: ListTile(
                      // <<<--- AÑADIDO (para TC-004)
                      key: Key('chat_item_${chat.id}'),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.secondary.withOpacity(0.96),
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      title: Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: (chat.lastMessage != null && chat.lastMessage!.isNotEmpty)
                          ? Text(
                              chat.lastMessage!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              " ",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white38,
                                  ),
                            ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatView(
                              chatId: chat.id,
                              currentUserId: currentUser!.userId,
                              otherUserName: displayName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: currentUser == null
          ? null
          : FloatingActionButton(
              // <<<--- AÑADIDO (para TC-003)
              key: const Key('chats_new_chat_fab'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectUserForChatView(currentUser: currentUser),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              tooltip: 'Nuevo chat',
              elevation: 4,
              child: const Icon(Icons.chat, color: Colors.white, size: 32),
            ),
    );
  }
}