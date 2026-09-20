import 'package:class2808/presentation/dos/dos_screen.dart';
import 'package:class2808/presentation/shared/drawer_custom.dart';
import 'package:class2808/presentation/uno/uno_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerCustom(),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Home'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text('Saludo'),
            subtitle: Text('Esto es un redireccionamiento como modal a saludo'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UnoScreen()),
            ),
          ),
          ListTile(
            trailing: Icon(Icons.arrow_forward),
            title: Text('Despido'),
            subtitle: Text(
              'Esto es un redireccionamiento como modal a despido',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DosScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
