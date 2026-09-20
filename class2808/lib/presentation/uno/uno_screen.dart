import 'package:flutter/material.dart';

final List<Widget> _screens = [
  Text('Primera tab pantalla uno'),
  Text('Segunda tab pantalla uno'),
  Text('Tercera tab pantalla uno')
];

class UnoScreen extends StatefulWidget {
  const UnoScreen({super.key});

  @override
  State<UnoScreen> createState() => _UnoScreenState();
}

class _UnoScreenState extends State<UnoScreen> {
   int _indicador = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Menu inferior'),
        centerTitle: true, 
      ),
      body: Center(
        child: _screens[_indicador],
      ),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _indicador,
      onTap: (value) => setState(() {
        setState(() {
          _indicador = value;
        });
      }),  
      items: 
      [
        BottomNavigationBarItem(
          icon: Icon(Icons.ad_units_outlined),
          label: 'tab1',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.ad_units_outlined),
          label: 'tab2',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.ad_units_outlined), 
        label: 'tab3')
      ]),
    );
  }
}