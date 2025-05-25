import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart'; // <- IMPORTANTE para UserModel
import '../../providers/user_provider.dart'; // <- Asegúrate de importar el UserProvider
import 'chat_view.dart';
import 'select_user_for_chat_view.dart';

class ChatsListView extends StatefulWidget {
  const ChatsListView({Key? key}) : super(key: key);

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
      // Cargar usuarios también (¡importante para los nombres!)
      Provider.of<UserProvider>(context, listen: false).loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = Provider.of<AuthProvider>(context).currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus Chats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: chatProvider.userChats.isEmpty
          ? const Center(child: Text('No tienes chats aún.'))
          : ListView.builder(
              itemCount: chatProvider.userChats.length,
              itemBuilder: (context, index) {
                final chat = chatProvider.userChats[index];
                final otherUserId = chat.participantIds.firstWhere((id) => id != currentUser?.userId);

                // Buscar el usuario real por su ID
                final otherUser = userProvider.users.firstWhere(
                  (u) => u.userId == otherUserId,
                  orElse: () => UserModel(
                    userId: otherUserId,
                    email: '',
                    fullName: 'Usuario',
                    role: '',
                    createdAt: Timestamp.now(),
                    dateOfBirth: null,
                    phoneNumber: null,
                    idNumber: null,
                  ),
                );

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Chat con: ${otherUser.fullName}'),
                  subtitle: Text(chat.lastMessage ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatView(
                          chatId: chat.id,
                          currentUserId: currentUser!.userId,
                          otherUserName: otherUser.fullName, // <-- Ya lo envías por nombre real
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: currentUser == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectUserForChatView(currentUser: currentUser),
                  ),
                );
              },
              child: const Icon(Icons.chat),
              tooltip: 'Nuevo chat',
            ),
    );
  }
}
