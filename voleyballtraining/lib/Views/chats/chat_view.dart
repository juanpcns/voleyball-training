import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../Styles/colors/app_colors.dart';
import '../Styles/templates/home_view_template.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String? otherUserName; // opcional, para mostrar el nombre del contacto

  const ChatView({
    super.key,
    required this.chatId,
    required this.currentUserId,
    this.otherUserName,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = MessageModel(
      senderId: widget.currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );

    await Provider.of<ChatProvider>(context, listen: false)
        .sendMessage(widget.chatId, message);

    _controller.clear();

    // Scroll al final
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return "$hour:$min";
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return HomeViewTemplate(
      title: widget.otherUserName ?? 'Chat',
      body: Column(
        children: [
          // Mensajes (en tiempo real)
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatProvider.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('No hay mensajes aún.'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  padding: const EdgeInsets.only(top: 16, bottom: 6),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg.senderId == widget.currentUserId;
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: isMine ? 60 : 12,
                          right: isMine ? 12 : 60,
                          top: 6,
                          bottom: 6,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isMine
                              ? AppColors.primary.withOpacity(0.92)
                              : Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMine
                                ? const Radius.circular(16)
                                : const Radius.circular(4),
                            bottomRight: isMine
                                ? const Radius.circular(4)
                                : const Radius.circular(16),
                          ),
                          border: Border.all(
                            color: isMine
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.13),
                            width: 1.1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMine ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(msg.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.57),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Campo de texto para enviar mensajes
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      // <<<--- AÑADIDO (para TC-004)
                      key: const Key('chat_message_field'),
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Escribe tu mensaje...",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    // <<<--- AÑADIDO (para TC-004)
                    key: const Key('chat_send_button'),
                    onPressed: () => _sendMessage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}