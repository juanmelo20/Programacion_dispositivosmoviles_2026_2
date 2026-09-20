import 'package:class2808/presentation/dos/dos_screen.dart';
import 'package:class2808/presentation/uno/uno_screen.dart';
import 'package:flutter/material.dart';

class DrawerCustom extends StatelessWidget {
  const DrawerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero, //para que no tenga padding en el espacio de la camara del celular
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, //minimo espacio entre los textos
                            crossAxisAlignment: CrossAxisAlignment
                                .start, //alinear a la izquierda
                            children: [
                              Text(
                                'Juan Melo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'titulo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Direccion 1'),
                  onTap: () {
                    Navigator.pop(context); // Cierra el Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnoScreen(),
                      ),
                    ); // Cierra el Drawer
                  },
                ),
                ListTile(
                  title: Text('Direccion 2'),
                  onTap: () {
                    Navigator.pop(context); // Cierra el Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DosScreen(),
                      ),
                    ); // Cierra el Drawer
                  },
                ),
              ],
            ),
          ),
          ListTile(title: Text('Item 1')),
        ],
      ),
    );
  }
}
