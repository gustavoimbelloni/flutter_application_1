import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'messagepage.dart';

class ChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: Text('Mensagens Recebidas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Messages')
            .where('receiverEmail', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Obter os emails únicos dos remetentes que enviaram mensagens ao usuário logado
          final messages = snapshot.data!.docs;
          final chatUsers = _getUniqueSenders(messages, userEmail);

          return ListView.builder(
            itemCount: chatUsers.length,
            itemBuilder: (context, index) {
              final chatUserEmail = chatUsers[index];
              return ListTile(
                title: Text(chatUserEmail),
                onTap: () {
                  // Navega para a página do chat com o usuário selecionado
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagePage(
                        chatWithUserEmail: chatUserEmail,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<String> _getUniqueSenders(
      List<QueryDocumentSnapshot> messages, String? userEmail) {
    final chatUsers = <String>{};

    for (var message in messages) {
      final sender = message['senderEmail'];
      if (sender != userEmail) {
        chatUsers.add(sender);
      }
    }
    return chatUsers.toList();
  }
}
