import 'package:flutter/material.dart';
import 'package:flutter_application_1/componentes/my_list_tile.dart';
import 'package:flutter_application_1/pages/registerpet_page.dart';
import 'package:flutter_application_1/pages/ajudapage.dart';
import 'package:flutter_application_1/pages/messagepage.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cabeçalho e opções de menu
          Column(
            children: [
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              // Opção Home
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),

              // Opção Profile
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),

              // Opção Cadastro de Pet
              MyListTile(
                icon: Icons.pets,
                text: 'C A D A S T R O - P E T',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPetScreen()),
                  );
                },
              ),

              // Opção Mensagens
              MyListTile(
                icon: Icons.message,
                text: 'M E N S A G E N S',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessagePage()),
                  );
                },
              ),

              // Opção Ajuda
              MyListTile(
                icon: Icons.help,
                text: 'A J U D A',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AjudaPage()),
                  );
                },
              ),
            ],
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
              text: 'S A I R',
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
