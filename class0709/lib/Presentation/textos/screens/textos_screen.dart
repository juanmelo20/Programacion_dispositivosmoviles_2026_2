import 'package:class0709/Presentation/textos/widget/texto_widget.dart';
import 'package:flutter/material.dart';

class TextosScreen extends StatelessWidget {
  const TextosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("hola Textos Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Text("Texto h1", style: textTheme.displayLarge),
            Text("Texto h2", style: textTheme.displayMedium ),
            Text("Texto h3", style: textTheme.displaySmall),
            TextoWidget(text: "Texto h1", type: TextType.h1), 
            TextoWidget(text: "Texto h2", type: TextType.h2),
            TextoWidget(text: "Texto h3", type: TextType.h3),
            TextoWidget(text: "Texto h4", type: TextType.h4),
            TextoWidget(text: "Texto p", type: TextType.p),
          ],
        ),
      ),
    );
  }
}