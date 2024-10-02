import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
    };
  }

  static Message fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      senderId: map['senderId'] ?? '', // Garantindo que não seja null
      receiverId: map['receiverId'] ?? '', // Garantindo que não seja null
      text: map['text'] ?? '', // Garantindo que não seja null
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
