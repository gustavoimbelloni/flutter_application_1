import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatUserId;
  final String chatUserEmail;

  const ChatScreen({
    Key? key,
    required this.chatUserId,
    required this.chatUserEmail,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? username; // Para armazenar o nome de usuário

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  // Função para buscar o nome de usuário na coleção 'Users'
  Future<void> _fetchUsername() async {
    try {
      final userPostDoc = await FirebaseFirestore.instance
          .collection('User Posts')
          .where('UserEmail', isEqualTo: widget.chatUserEmail)
          .limit(1)
          .get();

      if (userPostDoc.docs.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userPostDoc.docs[0].id)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username']; // Buscando o campo 'username'
          });
        } else {
          print('Usuário do chat não encontrado no Firestore.');
        }
      } else {
        print('Usuário não encontrado na coleção User Posts.');
      }
    } catch (e) {
      print('Erro ao buscar o nome de usuário: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('Messages').add({
          'senderEmail': user.email,
          'receiverEmail': widget.chatUserEmail,
          'message': _messageController.text,
          'timestamp': Timestamp.now(),
        });

        _messageController.clear(); // Limpa o campo de entrada após enviar
      }
    }
  }

  void editMessage(String messageId, String newText) {
    FirebaseFirestore.instance.collection('Messages').doc(messageId).update({
      'message': newText,
    });
  }

  void _showEditDialog(String messageId, String currentText) {
    TextEditingController _editController =
        TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Mensagem"),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(hintText: "Nova Mensagem"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_editController.text.isNotEmpty) {
                  editMessage(messageId, _editController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Salvar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  void deleteMessage(String messageId) {
    FirebaseFirestore.instance.collection('Messages').doc(messageId).delete();
  }

  void _confirmDelete(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Excluir Mensagem"),
          content: Text("Tem certeza que deseja excluir esta mensagem?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                deleteMessage(messageId);
                Navigator.pop(context);
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat com ${widget.chatUserEmail}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Messages')
                  .where('senderEmail',
                      isEqualTo: FirebaseAuth.instance.currentUser!.email)
                  .where('receiverEmail', isEqualTo: widget.chatUserEmail)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    print('Mensagem: ${message['message']}');
                    print('Email do Remetente: ${message['senderEmail']}');
                    return ListTile(
                      title:
                          Text(message['message'] ?? 'Mensagem não disponível'),
                      subtitle: Text(
                          message['senderEmail'] ?? 'Email não disponível'),
                      onLongPress: () {
                        _showEditDialog(
                            messages[index].id, message['message'] ?? '');
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _confirmDelete(messages[index].id);
                        },
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
                    decoration:
                        InputDecoration(labelText: 'Digite sua mensagem...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed:
                      _sendMessage, // Corrigido para chamar o método certo
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
