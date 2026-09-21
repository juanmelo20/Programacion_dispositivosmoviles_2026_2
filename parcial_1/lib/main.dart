import 'package:parcial_1/presentation/presentacion.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parcial 1 - Mobile Devices',
      theme: AppTheme().themeData(),
      home: const HomeScreen(),
    );
  }
}