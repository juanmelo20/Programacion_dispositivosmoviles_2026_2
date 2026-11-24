import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Cierra una página de detalle o formulario devolviendo [result].
///
/// Si la página se abrió escribiendo la URL (no hay a dónde volver, por
/// ejemplo al recargar en Chrome), va al módulo [fallback].
void closePage<T extends Object?>(
  BuildContext context, {
  required String fallback,
  T? result,
}) {
  if (context.canPop()) {
    context.pop<T>(result);
  } else {
    context.go(fallback);
  }
}

/// Flecha "atrás" de las páginas de detalle. Si hay historial, el AppBar
/// pone la suya (devuelve null); si se entró por URL, lleva al módulo.
Widget? pageBackButton(BuildContext context, String fallback) {
  if (Navigator.of(context).canPop()) return null;
  return IconButton(
    icon: const BackButtonIcon(),
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: () => context.go(fallback),
  );
}
