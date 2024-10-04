import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth
        .instance.currentUser?.email; // Obtém o email do usuário logado

    return Scaffold(
      appBar: AppBar(title: Text('Mensagens')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Messages')
            .where('senderEmail', isEqualTo: userEmail)
            .where('receiverEmail',
                isEqualTo: userEmail) // Filtro para mensagens recebidas
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(message['message'] ?? 'Mensagem não disponível'),
                subtitle: Text(
                    'De: ${message['senderEmail'] ?? 'Email não disponível'}'),
              );
            },
          );
        },
      ),
    );
  }
}
