import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/componentes/button.dart';
import 'package:flutter_application_1/componentes/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //controladores de edição de texto
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // cadastrar usuário
  void signUp() async {
    // mostrar círculo de carregamento
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // certifique-se de que as senhas correspondam
    if (passwordTextController.text != confirmPasswordTextController.text) {
      // círculo de carregamento
      Navigator.pop(context);
      // mostrar erro ao usuário
      displayMessage("As senhas não coincidem!");
      return;
    }

    // tente criar o usuário
    try {
      // crie o usuário
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // após criar o usuário, crie um novo documento no Cloud Firestore chamado Usuários
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email!)
          .set({
        'username':
            emailTextController.text.split('@')[0], // nome de usuário inicial
        'bio': 'Empty bio..' // biografia inicialmente vazia
        // adicione quaisquer campos adicionais conforme necessário
      });

      // círculo de carregamento
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop círculo de carregamento
      Navigator.pop(context);
      // mostrar erro ao usuário
      displayMessage(e.code);
    }
  }

  // exibir uma mensagem de diálogo
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                const Icon(
                  Icons.pets,
                  size: 100,
                ),

                SizedBox(height: 50),

                // mensagem de boas-vindas
                Text(
                  "Vamos criar uma conta para você",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                SizedBox(height: 25),

                // campo de texto do e-mail
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                SizedBox(height: 10),

                // campo de texto de senha
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Senha',
                  obscureText: true,
                ),

                SizedBox(height: 10),

                // campo de texto confirmar senha
                MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: 'Confirme Senha',
                  obscureText: true,
                ),

                SizedBox(height: 25),

                // botão de inscrição
                MyButton(
                  onTap: signUp,
                  text: 'Inscrever-se',
                ),

                // vá para a página de registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "já tem uma conta?",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Conecte-se agora",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
