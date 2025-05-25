// lib/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Factory que soporta Timestamp (Firestore), DateTime y String (ISO8601)
  factory MessageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedTimestamp;
    if (map['timestamp'] is Timestamp) {
      parsedTimestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is DateTime) {
      parsedTimestamp = map['timestamp'] as DateTime;
    } else if (map['timestamp'] is String) {
      parsedTimestamp = DateTime.parse(map['timestamp']);
    } else {
      throw Exception('Formato de fecha no soportado: ${map['timestamp'].runtimeType}');
    }

    return MessageModel(
      id: id,
      senderId: map['senderId'],
      text: map['text'],
      timestamp: parsedTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp, // Firestore acepta DateTime
    };
  }
}
