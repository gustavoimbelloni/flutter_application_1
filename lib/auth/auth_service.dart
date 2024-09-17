import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Método para fazer login com o Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Iniciar o processo de login do Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtenha os detalhes de autenticação do pedido de login
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Crie uma nova credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Tente fazer o login do usuário com as credenciais do Google
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Verifique se o documento do usuário existe no Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .get();

      // Se o documento não existir, crie um novo
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.email)
            .set({
          'username': userCredential.user!.displayName ?? 'Usuário',
          'bio': 'Empty bio..',
          // Adicione outros campos se necessário
        });
      }

      return userCredential;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
