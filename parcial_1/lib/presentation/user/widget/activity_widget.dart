import 'package:flutter/material.dart';

/// Item reutilizable para la lista "My Activities"
class ActivityWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActivityWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlueAccent),
      title: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}