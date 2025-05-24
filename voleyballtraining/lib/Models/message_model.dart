import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id;                // Hacemos el id opcional
  final String senderId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    this.id,                       // Ahora es opcional
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Factory para crear desde Firestore (asegúrate de soportar id opcional)
  factory MessageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MessageModel(
      id: id, // puede venir nulo si lo usas así
      senderId: map['senderId'],
      text: map['text'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
