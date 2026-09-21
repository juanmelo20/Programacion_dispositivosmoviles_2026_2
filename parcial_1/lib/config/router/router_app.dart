import 'package:parcial_1/presentation/presentacion.dart';


const List<RouterModel> route = [
  RouterModel(
    title: 'Home',
    description: 'Main screens',
    name: 'home',
    widget: HomeScreen(),
  ),
  RouterModel(
    title: 'User',
    description: 'User screen with general personal information',
    name: 'user',
    widget: UserScreen(),
  ),
];