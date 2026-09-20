import 'package:flutter/material.dart';

class DosScreen extends StatelessWidget {
  const DosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de pestañas(Tabs)
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text('Menu superior'),
          centerTitle: true,
          bottom: TabBar(
            tabs:  [
              Tab(
                icon: Icon(Icons.ad_units_outlined),
                text: 'tab1',
              ),
              Tab(
                icon: Icon(Icons.ad_units_outlined),
                text: 'tab2',
              ),
            ], 
          ),
        ),
      

        body: 
            TabBarView(
              children: [
                Center(child: Text('Primera tab pantalla dos')),
                Center(child: Text('Segunda tab pantalla dos')),
              ], 
          ),
      ),
    );
  }
}