import 'dart:async';

import 'package:flutter/material.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/location_model.dart';

/// Carrusel (PageView) con los puntos ecológicos activos.

class EcoPointsCarousel extends StatefulWidget {
  const EcoPointsCarousel({
    super.key,
    required this.points,
    this.onTap,
    this.autoPlay = true,
  });

  final List<LocationModel> points;
  final ValueChanged<LocationModel>? onTap;
  final bool autoPlay;

  @override
  State<EcoPointsCarousel> createState() => _EcoPointsCarouselState();
}

class _EcoPointsCarouselState extends State<EcoPointsCarousel> {
  static const Duration _interval = Duration(seconds: 2);

  final PageController _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant EcoPointsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page >= widget.points.length) _page = 0;
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (!widget.autoPlay || widget.points.length < 2) return;
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.points.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() { //se cancela el timer y se libera el controlador de la página para evitar fugas de memoria.
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.points.length,
            onPageChanged: (page) {
              setState(() => _page = page);
              _restartTimer();
            },
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _EcoPointCard(
                point: widget.points[index],
                index: index,
                onTap: widget.onTap == null
                    ? null
                    : () => widget.onTap!(widget.points[index]),
              ),
            ),
          ),
        ),
        if (widget.points.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.points.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _page ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EcoPointCard extends StatelessWidget {
  const _EcoPointCard({required this.point, required this.index, this.onTap});

  final LocationModel point;
  final int index;
  final VoidCallback? onTap;

  // Paletas verdes/azules para que cada tarjeta se distinga.
  static const List<List<Color>> _gradients = [
    [Color(0xFF2E7D32), Color(0xFF00897B)],
    [Color(0xFF00796B), Color(0xFF0277BD)],
    [Color(0xFF558B2F), Color(0xFF2E7D32)],
    [Color(0xFF00695C), Color(0xFF4E342E)],
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = _gradients[index % _gradients.length];
    final description = point.description?.trim() ?? '';

    return Material(
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -22,
                child: Icon(
                  Icons.recycling_rounded,
                  size: 130,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.place_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      point.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      t.pointActiveContainers(point.activeContainerCount),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
