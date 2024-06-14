import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_or_register.dart';
import '../pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // usuário está logado
          if (snapshot.hasData) {
            return const HomePage();
          }

          // usuário NÃO está logado
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
