import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/componentes/comment.dart';
import 'package:flutter_application_1/componentes/comment_button.dart';
import 'package:flutter_application_1/componentes/delete_button.dart';
import 'package:flutter_application_1/componentes/like_button.dart';
import 'package:flutter_application_1/helper/helper_methods.dart';
import 'package:flutter_application_1/pages/chat_screen.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Classe WallPost para exibir uma postagem no mural
class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final String imageUrl;

  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    required this.imageUrl,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // Imagem selecionada pelo usuário

  // Método para escolher imagem da galeria
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await uploadImage(); // Carrega a imagem escolhida
    }
  }

  // Método para fazer upload da imagem para o Firebase Storage
  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    String filePath = 'post_images/${widget.postId}/${DateTime.now()}.png';
    File file = _imageFile!;

    try {
      await FirebaseStorage.instance.ref(filePath).putFile(file);
      String downloadURL =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();

      // Atualiza o Firestore com a URL da imagem
      await FirebaseFirestore.instance
          .collection('Pets')
          .doc(widget.postId)
          .update({
        'imageUrl': downloadURL,
      });
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
    }
  }

  // Usuario atual
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false; // Estado da curtida

  // Controlador de texto para comentários
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Verifica se a postagem já foi curtida pelo usuário atual
    isLiked = widget.likes.contains(currentUser.email);
  }

  // Alternar estado da curtida
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Pets').doc(widget.postId);

    if (isLiked) {
      // Se a postagem foi curtida, adiciona o e-mail do usuário ao campo 'Likes'
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // Se a postagem não foi curtida, remove o e-mail do usuário do campo 'Likes'
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // Adicionar um comentário à postagem
  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("Pets")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  // Mostrar diálogo para adicionar comentários
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adicionar comentário"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Escreva um comentário.."),
        ),
        actions: [
          // Botão Cancelar
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear(); // Limpa o controlador
            },
            child: Text("Cancelar"),
          ),
          // Botão Postar
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              Navigator.pop(context);
              _commentTextController.clear(); // Limpa o controlador
            },
            child: Text("Postar"),
          ),
        ],
      ),
    );
  }

  // Excluir a postagem
  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deletar Postagem"),
        content: const Text("Tem certeza de que deseja excluir esta postagem?"),
        actions: [
          // Botão Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          // Botão Excluir
          TextButton(
            onPressed: () async {
              // Exclui os comentários da postagem
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              // Exclui a postagem
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("postagem excluída"))
                  .catchError((error) =>
                      print("não foi possível excluir a postagem: $error"));

              Navigator.pop(context); // Fecha o diálogo
            },
            child: const Text("Deletar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exibir imagem associada ao post
          if (widget.imageUrl.isNotEmpty) Image.network(widget.imageUrl),

          const SizedBox(height: 10),

          // Botão para escolher imagem
          if (_imageFile == null)
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: pickImage,
            ),

          // Exibir imagem escolhida
          if (_imageFile != null) Image.file(_imageFile!),

          // Estrutura da postagem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grupo de texto (mensagem + e-mail do usuário)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensagem da postagem
                  Text(widget.message),

                  const SizedBox(height: 5),

                  // Informações do usuário
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        " - ",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
              // Botão excluir (apenas se o usuário for o autor da postagem)
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),

          const SizedBox(width: 20),

          // Botões de interação
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botão curtir
              Column(
                children: [
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  const SizedBox(height: 5),
                  // Contagem de curtidas
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Botão comentar
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(height: 5),
                  // Contagem de comentários (por enquanto sempre mostra 0)
                  Text('0', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 10),
              // Botão de chat
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.blue),
                    onPressed: () async {
                      // Pegar o documento de postagem para obter o email do usuário que postou
                      final postDoc = await FirebaseFirestore.instance
                          .collection('User Posts')
                          .doc(widget.postId)
                          .get();

                      // Verifica se o documento existe e navega para a tela de chat
                      if (postDoc.exists && postDoc.data() != null) {
                        final postUserEmail = postDoc.data()!['UserEmail']
                            as String; // Acesse o email do usuário aqui

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatUserId: widget.postId,
                              chatUserEmail: postUserEmail,
                            ),
                          ),
                        );
                      } else {
                        print(
                            'Erro: o documento da postagem não foi encontrado.');
                      }
                    },
                  ),
                  const SizedBox(height: 5),
                  const Text('Chat', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // StreamBuilder para escutar comentários em tempo real
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Pets")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Lista de comentários
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;

                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
