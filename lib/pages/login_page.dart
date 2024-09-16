import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/componentes/button.dart';
import 'package:flutter_application_1/componentes/text_field.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signInWithGoogle() async {
    try {
      // Mostra circulo de carregamento
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Instancia do GoogleSignIn
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Fechar dialogo se o usuario cancelar o login
        Navigator.pop(context);
        return;
      }

      // Autenticação no Firebase
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login no Firebase com o token do Google
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Fechar o circulo de carregamento
      if (context.mounted) Navigator.pop(context);

      // Redirecionar para a pagina inicial apos o login bem-sucedido
      Navigator.pushReplacementNamed(context, '/home_page');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.message ?? "Erro durante o login com Google");
    }
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

                GestureDetector(
                  onTap:
                      signInWithGoogle, // Chama o método para login com Google
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/google_logo.png',
                          height: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Entrar com Google',
                          style: TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

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
