import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_model.dart';
import 'chat_view.dart';

class ChatsListView extends StatefulWidget {
  const ChatsListView({Key? key}) : super(key: key);

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  @override
  void initState() {
    super.initState();
    // Cargar los chats del usuario logueado
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUserModel;
    if (currentUser != null) {
      Provider.of<ChatProvider>(context, listen: false).loadUserChats(currentUser.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
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

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Chat con: $otherUserId'),
                  subtitle: Text(chat.lastMessage ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatView(
                          chatId: chat.id,
                          currentUserId: currentUser!.userId,
                          // Puedes agregar el nombre real si lo tienes (opcional)
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
                // Aquí deberías llevar a una pantalla para seleccionar usuario
                // Por ahora solo muestra un mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función de nuevo chat próximamente.')),
                );
              },
              child: const Icon(Icons.chat),
              tooltip: 'Nuevo chat',
            ),
    );
  }
}
