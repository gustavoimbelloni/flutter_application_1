import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/componentes/drawer.dart';
import 'package:flutter_application_1/componentes/wall_post.dart';
import 'package:flutter_application_1/componentes/text_field.dart';
import 'package:flutter_application_1/helper/helper_methods.dart';

import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // usuario
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Controlador de Texto
  final textController = TextEditingController();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      }).then((_) {
        textController.clear(); // Limpa o campo de texto após a postagem
        print('Mensagem postada com sucesso');
        setState(() {}); // Atualiza a interface
      }).catchError((error) {
        print('Erro ao postar a mensagem: $error');
      });
    } else {
      print('Campo de mensagem vazio');
    }
  }

  // navegue até a página de perfil
  void goToProfilePage() {
    // gaveta do menu pop
    Navigator.pop(context);

    // vá para a página de perfil
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Feed de notícias'),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            // parede de postagens
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // Entenda a mensagem
                        final post = snapshot.data!.docs[index];
                        final data = post.data() as Map<String, dynamic>;
                        final imageUrl = data.containsKey('imageUrl')
                            ? data['imageUrl']
                            : '';

                        return WallPost(
                          message: data['Message'],
                          user: data['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(data['Likes'] ?? []),
                          time: formatDate(data['TimeStamp']),
                          imageUrl: imageUrl,
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            // postar mensagem
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  // campo de texto
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Escreva algo..',
                      obscureText: false,
                    ),
                  ),

                  // botão postar
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.arrow_circle_up),
                  )
                ],
              ),
            ),

            Text(
              "Logado como: " + currentUser.email!,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
