import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/message_model.dart';
import '../Models/chat_model.dart'; // Importa tu modelo de chat

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener mensajes en tiempo real de un chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data(), id: doc.id); // Asigna el id
      }).toList();
    });
  }

  // Enviar mensaje
  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap()); // El id lo pone firestore
  }

  // ========================
  // ¡NUEVO!: Obtener chats de usuario
  // ========================
  Future<List<ChatModel>> getUserChats(String userId) async {
    final query = await _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId) // <-- Ajusta el nombre si usas otro campo
        .get();

    return query.docs
        .map((doc) => ChatModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  // Ejemplo: obtener o crear chatId (ajusta la lógica a tu necesidad)
  Future<String> getOrCreateChatId(List<String> userIds) async {
    // Busca si ya existe un chat con esos dos usuarios exactos
    final existingChats = await _firestore
        .collection('chats')
        .where('participantIds', isEqualTo: userIds)
        .get();

    if (existingChats.docs.isNotEmpty) {
      return existingChats.docs.first.id;
    }

    // Si no existe, crea uno nuevo
    final newChat = await _firestore.collection('chats').add({
      'participantIds': userIds,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }
}
