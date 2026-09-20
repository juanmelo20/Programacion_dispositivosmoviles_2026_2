import 'package:class0709/Presentation/presentacion.dart';
import 'package:class0709/config/router/router_model.dart';

const List<RouterModel> route = [
  RouterModel(
    title: 'Button',
    description: 'Vista con todos los botones',
    name: 'button',
    widget: BotonesScreen(),
  ),
  RouterModel(
    title: 'Text',
    description: 'Vista con todos los textos',
    name: 'text',
    widget: TextosScreen(),
  ),
  RouterModel(
    title: 'Card',
    description: 'Vista con card',
    name: 'card',
    widget: CardCustom(),
  ),
];
