import 'package:flutter/material.dart';

class BotonesScreen extends StatelessWidget {
  const BotonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hola Botones Screen"),),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Wrap(
          runSpacing: 20,
          spacing: 20,
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Elevated Button ")),
            ElevatedButton(onPressed: null, child: Text("Elevated Button disable")),
            ElevatedButton.icon(onPressed: () {},
            icon: Icon(Icons.add), label: Text("elevated Button Icon")),
            FilledButton(onPressed: () {}, child: Text("Filled Button")),
            FilledButton(onPressed: null, child: Text("Filled Button disable")),
            FilledButton.icon(onPressed: () {}, icon: Icon(Icons.add), label: Text("Filled Button Icon")),
            OutlinedButton(onPressed: () {}, child: Text("Outlined Button")),
            OutlinedButton(onPressed: null, child: Text("Outlined Button disable")),
            OutlinedButton.icon(onPressed: () {}, icon: Icon(Icons.add), label: Text("Outlined Button Icon")), 
            TextButton(onPressed: () {}, child: Text("Text Button")),
            TextButton(onPressed: null, child: Text("Text Button disable")),
            TextButton.icon(onPressed: () {}, icon: Icon(Icons.add), label: Text("Text Button Icon")),
            IconButton(onPressed: () {}, icon: Icon(Icons.add)),
            IconButton(onPressed: null, icon: Icon(Icons.add)),
            IconButton(onPressed: () {}, 
            icon: Icon(Icons.add), tooltip: "Icon Button",
            style: ButtonStyle(),),


          ],
        ),
      ),
    );
  }
}