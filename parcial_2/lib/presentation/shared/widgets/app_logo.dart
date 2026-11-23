import 'package:flutter/material.dart';

/// Logo de EcoTrack: ícono de reciclaje dentro de un círculo.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.inverted = false});

  final double size;

  /// true = logo claro para poner sobre el fondo verde del encabezado.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = inverted ? scheme.onPrimary : scheme.primaryContainer;
    final foreground = inverted ? scheme.primary : scheme.onPrimaryContainer;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.recycling_rounded,
        size: size * 0.55,
        color: foreground,
      ),
    );
  }
}
