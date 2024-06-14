import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/componentes/button.dart';
import 'package:flutter_application_1/componentes/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controladores de edição de texto
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  // fazer login do usuário
  void singIn() async {
    // mostrar círculo de carregamento
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // tente fazer login
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // círculo de carregamento
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // círculo de carregamento
      Navigator.pop(context);
      // exibir mensagem de erro
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                const Icon(
                  Icons.pets,
                  size: 100,
                ),

                const SizedBox(height: 50),

                // mensagem de boas-vindas de volta
                Text(
                  "Bem-vindo de volta, você fez falta!",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 25),

                // campo de texto do e-mail
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // campo de texto de senha
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Senha',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // botão de login

                MyButton(
                  onTap: singIn,
                  text: 'Entrar',
                ),

                const SizedBox(height: 25),

                // vai para a página de cadastro

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Não é um membro?",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Registrar agora",
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
