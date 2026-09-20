import 'package:flutter/material.dart';

class CardCustom extends StatelessWidget {
  const CardCustom({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Card Custom"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  Card(
                    elevation: 10,
                    color: themeColor.primaryContainer,
                    child:Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Text("Card Custom"),
                          Text("Card Custom"),
                          Text("Card Custom"),
                        ],
                      ),
                  ),
                  ),
                  Card(
                    shape: 
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.red, width: 2)
                    ),
                    elevation: 10,
                    child:Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Text("Card Custom"),
                          Text("Card Custom"),
                          Text("Card Custom"),
                        ],
                      ),
                    )
                  )
                ],
              ),
            )
          ],
        ),
      )
     
    );
  }
}