import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/componentes/comment.dart';
import 'package:flutter_application_1/componentes/comment_button.dart';
import 'package:flutter_application_1/componentes/delete_button.dart';
import 'package:flutter_application_1/componentes/like_button.dart';
import 'package:flutter_application_1/helper/helper_methods.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    required this.imageUrl, // Adicione este parâmetro
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Escolher imagem da galeria
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Carregar a imagem
      await uploadImage();
    }
  }

  // Fazer upload da imagem para o Firebase Storage
  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    // Caminho para salvar a imagem no Firebase Storage
    String filePath = 'post_images/${widget.postId}/${DateTime.now()}.png';
    File file = _imageFile!;

    try {
      await FirebaseStorage.instance.ref(filePath).putFile(file);
      String downloadURL =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();

      // Atualizar o Firestore com a URL da imagem
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

  // usuario
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // controlador de texto de comentário
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // alternar curtida
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Acesse o documento pelo Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Pets').doc(widget.postId);

    if (isLiked) {
      // se a postagem já tiver sido curtida, adicione o e-mail do usuário ao campo 'Curtir'
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // se a postagem não tiver sido curtida, remova o e-mail do usuário do campo 'Curtir'
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // Adicione um comentário
  void addComment(String commentText) {
    // escreva o comentário para firestore na coleção de comentários desta postagem
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

  // mostrar uma caixa de diálogo para adicionar comentários
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
          // botão cancelar
          TextButton(
            onPressed: () {
              // caixa
              Navigator.pop(context);

              //limpar controlador
              _commentTextController.clear();
            },
            child: Text("Cancelar"),
          ),

          // botão postar
          TextButton(
            onPressed: () {
              // adicionar comentário
              addComment(_commentTextController.text);

              // caixa
              Navigator.pop(context);

              // limpar controlador
              _commentTextController.clear();
            },
            child: Text("Postar"),
          ),
        ],
      ),
    );
  }

  // delete a postagem
  void deletePost() {
    // mostrar uma caixa de diálogo pedindo confirmação antes de excluir a postagem
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deletar Postagem"),
        content: const Text("Tem certeza de que deseja excluir esta postagem?"),
        actions: [
          // BOTÃO CANCELAR
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),

          // BOTÃO EXCLUIR
          TextButton(
            onPressed: () async {
              // exclua os comentários do firestore primeiro
              //( se você apenas excluir a postagem, os comentários ainda serão armazenados no firestore )
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

              // então exclua a postagem
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("postagem excluída"))
                  .catchError((error) =>
                      print("não foi possível excluir a postagem: $error"));

              // dispensar o diálogo
              Navigator.pop(context);
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

          // parede de postagem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // grupo de texto (mensagem + e-mail do usuário)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // mensagem
                  Text(widget.message),

                  const SizedBox(height: 5),

                  // usuario
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

              // botão excluir
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),

          const SizedBox(width: 20),

          // botões
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Curtir
              Column(
                children: [
                  // botão curtir
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),

                  const SizedBox(height: 5),

                  // contar curtida
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // COMENTE
              Column(
                children: [
                  // botão de comentários
                  CommentButton(onTap: showCommentDialog),

                  const SizedBox(height: 5),

                  // Contagem de comentários
                  Text(
                    '0',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // comentários abaixo da postagem
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Pets")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              //mostrar o círculo de carregamento se ainda não houver dados
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true, //para listas aninhadas
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  // receba o comentário
                  final commentData = doc.data() as Map<String, dynamic>;

                  // devolva o comentário
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
