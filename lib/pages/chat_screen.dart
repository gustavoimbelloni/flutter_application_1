import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message.dart';
import 'package:intl/intl.dart'; // Para formatar a data

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? username; // Para armazenar o nome de usuário

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  // Função para buscar o nome de usuário na coleção 'Users'
  Future<void> _fetchUsername() async {
    try {
      // Buscando o UserEmail correspondente ao chatUserId na coleção 'User Posts'
      final userPostDoc = await FirebaseFirestore.instance
          .collection('User Posts')
          .where('UserEmail', isEqualTo: widget.chatUserEmail)
          .limit(1)
          .get();

      if (userPostDoc.docs.isNotEmpty) {
        // O UserEmail foi encontrado, agora buscar o username na coleção 'Users'
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userPostDoc.docs[0].id) // Supondo que o id aqui é o userId
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

  void _sendMessage() {
    final user = _auth.currentUser;
    if (user != null && _messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('Messages').add({
        'senderId': user.uid,
        'receiverId': widget.chatUserId,
        'text': _messageController.text,
        'timestamp': Timestamp.now(),
      }).then((value) {
        print('Mensagem enviada: ${_messageController.text}');
      }).catchError((erro) {
        print('Erro ao enviar mensagem: $erro');
      });

      _messageController.clear();
    } else {
      print('Usuário não autenticado ou mensagem vazia.');
    }
  }

  void editMessage(String messageId, String newText) {
    FirebaseFirestore.instance.collection('Messages').doc(messageId).update({
      'text': newText,
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
              onPressed: () => Navigator.pop(context), // Fechar o diálogo
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                deleteMessage(messageId);
                Navigator.pop(context); // Fechar o diálogo
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
    final user = _auth.currentUser;

    // Verificando se o username foi recuperado
    if (user == null) {
      print('Erro: usuário não autenticado.');
      return Scaffold(
        appBar: AppBar(
          title: Text("Erro"),
        ),
        body: Center(
          child: Text("Erro: usuário não autenticado."),
        ),
      );
    }

    if (username == null) {
      // Se o username ainda não foi carregado, mostra uma mensagem de loading
      return Scaffold(
        appBar: AppBar(
          title: Text("Carregando..."),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat com $username"), // Exibe o username
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Messages')
                  .where('senderId', whereIn: [user.uid, widget.chatUserId])
                  .where('receiverId', whereIn: [user.uid, widget.chatUserId])
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhuma mensagem'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  final message = Message.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id);

                  String formattedTime =
                      DateFormat('HH:mm').format(message.timestamp.toDate());
                  return ListTile(
                    title: Text(message.text),
                    subtitle: Text("Enviada às $formattedTime"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(message.id, message.text);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(doc.id);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList();

                return ListView(children: messages);
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
                        InputDecoration(labelText: "Digite uma mensagem"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
