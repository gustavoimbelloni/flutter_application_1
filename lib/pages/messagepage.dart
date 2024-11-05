import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';

class MessagePage extends StatefulWidget {
  final String chatWithUserEmail;

  const MessagePage({super.key, required this.chatWithUserEmail});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat com ${widget.chatWithUserEmail}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: StreamZip([
                FirebaseFirestore.instance
                    .collection('Messages')
                    .where('senderEmail', isEqualTo: userEmail)
                    .where('receiverEmail', isEqualTo: widget.chatWithUserEmail)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                FirebaseFirestore.instance
                    .collection('Messages')
                    .where('senderEmail', isEqualTo: widget.chatWithUserEmail)
                    .where('receiverEmail', isEqualTo: userEmail)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final sentMessages = snapshot.data![0].docs;
                final receivedMessages = snapshot.data![1].docs;
                final messages = [...sentMessages, ...receivedMessages]
                  ..sort((a, b) =>
                      (b['timestamp'] as Timestamp).compareTo(a['timestamp']));

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    return Align(
                      alignment: message['senderEmail'] == userEmail
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: message['senderEmail'] == userEmail
                              ? Colors.blue[300]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          message['message'] ?? '',
                          style: TextStyle(
                              color: message['senderEmail'] == userEmail
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty && userEmail != null) {
      FirebaseFirestore.instance.collection('Messages').add({
        'message': messageText,
        'senderEmail': userEmail,
        'receiverEmail': widget.chatWithUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear(); // Limpa o campo de texto após enviar
    }
  }
}
