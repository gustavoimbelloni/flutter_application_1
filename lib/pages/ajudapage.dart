import 'package:flutter/material.dart';

class AjudaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajuda'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peça ajuda se o seu cão está perdido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Se procurou por todo o lado e o seu cão continua desaparecido, está na hora de avisar que o seu cão está perdido.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aqui você pode adicionar lógica para um formulário de contato ou outras opções de suporte
              },
              child: Text('Entrar em contato com o suporte'),
            ),
            SizedBox(height: 20),
            Text(
              'Quem deve contactar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Contacte o canil municipal, a polícia e a câmara municipal para saber que equipas recolhem animais da rua. Dê-lhes uma descrição do seu cão e indique-lhes quando e em que zona o seu cão foi visto pela última vez. Estas serão as entidades que serão contactadas se o seu cão desaparecido for reportado como animal errante ou se estiver envolvido nalgum acidente de carro. Algumas associações de proteção animal podem ser uma grande ajuda a localizar animais perdidos. Para ganhar tempo, tenha disponível estas informações, quando os contactar: cor do seu cão, idade, tamanho, raça, temperamento, identificação (coleira, chapa de identificação, microchip), local e quando se deu o desaparecimento, bem como os seus dados de contacto.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
