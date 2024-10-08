import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/componentes/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // usuario
  final currentUser = FirebaseAuth.instance.currentUser!;
  // todos os usuários
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  // editar campo
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // botão cancelar
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // botão salvar
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    // atualização no firebase
    if (newValue.trim().isNotEmpty) {
      // atualize apenas se houver algo no campo de texto
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Página de perfil"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(currentUser.email).snapshots(),
        builder: (context, snapshot) {
          // Verificar se os dados do usuario foram recuperados
          if (snapshot.hasData) {
            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            if (userData == null) {
              // Se o usuario não for encontrado no Firestore
              return Center(
                child: Text(
                  'Usuario não encontrado no Firestore.',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            }
            return ListView(
              children: [
                const SizedBox(height: 50),

                // imagem de perfil
                const Icon(
                  Icons.person,
                  size: 72,
                ),

                const SizedBox(height: 10),

                //e-mail do usuário
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 50),

                // Detalhes do usuario
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Meus detalhes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                // nome de usuário
                MyTextBox(
                  text: userData['username'] ?? 'Sem nome de usuário',
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),
                // bio
                MyTextBox(
                  text: userData['bio'] ?? 'Sem bio',
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 50),

                // user posts
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Minhas postagens',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // Erro ao carregar o perfil
            return Center(
              child: Text(
                'Erro ao carregar o perfil: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // Exibe o circulo de carregamento enquanto aguarda os dados
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
