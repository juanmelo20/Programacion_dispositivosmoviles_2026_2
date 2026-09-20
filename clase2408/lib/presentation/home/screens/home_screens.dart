import 'package:clase2408/presentation/rutaAbajo/ruta_abajo_screens.dart';
import 'package:flutter/material.dart';
import 'package:clase2408/presentation/rutaArriba/ruta_arriba_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text('Primera pagina'),
            subtitle: Text('Ir a la primera pagina'),
            leading: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RutaArribaScreens()),
              );
            },
          ),
          ListTile(
            title: Text('Segunda pagina'),
            subtitle: Text('Ir a la segunda pagina'),
            trailing: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RutaAbajoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
