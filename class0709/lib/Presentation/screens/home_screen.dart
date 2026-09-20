import 'package:class0709/config/router/router_app.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My App")),
      body: ListView.builder(
        itemCount: route.length,
        itemBuilder: (context, i) {
          final element = route[i];
          return ListTile(
            title: Text(element.name),
            subtitle: Text(element.description),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => element.widget),
              );
            },
          );
        },
      ),
    );
  }
}
