import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

   int contador = 0;

  @override
 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                contador == 20 ? null :
                setState(() {
                  contador++;
                });
              },
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () {
                contador == 20 ? null :
                setState(() {
                  contador--;
                });
              },
              child: const Icon(Icons.remove),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  contador = 0;
                });
              },
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
        appBar: AppBar(
          title: const Text("My App"),
          backgroundColor: Colors.deepPurpleAccent,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hello World'),
              const Text('Welcome to my app'),
              Text('Clicks: $contador'),
              Text(contador==20 ? "Ganaste" : "")
            ],
          ),
        ),
      )
    );
  }
}