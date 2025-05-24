import 'package:flutter/material.dart';
import '../Models/chat_model.dart';
import '../Models/message_model.dart';
import '../Repositories/chat_repository.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _chatRepo = ChatRepository();

  List<ChatModel> _userChats = [];
  List<ChatModel> get userChats => _userChats;

  // Cargar chats de un usuario
  Future<void> loadUserChats(String userId) async {
    _userChats = await _chatRepo.getUserChats(userId);
    notifyListeners();
  }

  // Stream de mensajes de un chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatRepo.getMessages(chatId); // El repo ya retorna los mensajes con id
  }

  // Enviar mensaje (NO pasamos id)
  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _chatRepo.sendMessage(chatId, message);
  }

  // Obtener o crear chatId para dos usuarios
  Future<String> getOrCreateChatId(List<String> userIds) {
    return _chatRepo.getOrCreateChatId(userIds);
  }
}
