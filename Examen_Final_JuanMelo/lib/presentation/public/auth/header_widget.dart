import 'package:flutter/material.dart';

/// Encabezado verde con ondas para la pantalla de login.
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key, required this.height, this.child});

  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Onda de fondo, más clara.
          ClipPath(
            clipper: const _WaveClipper(lift: 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.35),
                    scheme.tertiary.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          // Onda principal.
          ClipPath(
            clipper: const _WaveClipper(lift: 22),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.tertiary],
                ),
              ),
            ),
          ),
          if (child != null)
            Positioned.fill(child: SafeArea(bottom: false, child: child!)),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper({required this.lift});

  /// Cuánto sube la onda respecto al borde inferior.
  final double lift;

  @override
  Path getClip(Size size) {
    final bottom = size.height - lift;
    return Path()
      ..lineTo(0, bottom - 36)
      ..quadraticBezierTo(
        size.width * 0.25,
        bottom,
        size.width * 0.5,
        bottom - 24,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        bottom - 52,
        size.width,
        bottom - 20,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) =>
      oldClipper.lift != lift;
}
