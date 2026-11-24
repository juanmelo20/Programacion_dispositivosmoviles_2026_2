import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';

/// Indicador numérico (KPI) con ícono.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: tint),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuadrícula adaptable: 2 columnas en celular.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 150,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = math.max(
          2,
          math.min(4, ((width + spacing) / (minItemWidth + spacing)).floor()),
        );
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Tarjeta con título para una gráfica.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Dato de una gráfica.
class ChartItem {
  const ChartItem({required this.label, required this.value, this.color});

  final String label;
  final num value;
  final Color? color;
}

/// Barras horizontales (ej. residuos por punto ecológico).
class HorizontalBarChart extends StatelessWidget {
  const HorizontalBarChart({super.key, required this.items});

  final List<ChartItem> items;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final maxValue = items.fold<num>(0, (m, i) => math.max(m, i.value));

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.number(item.value, t.localeName),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _Bar(
                  fraction: maxValue == 0 ? 0 : item.value / maxValue,
                  color: item.color ?? theme.colorScheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 10,
        color: color.withValues(alpha: 0.14),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}

/// Columnas verticales (ej. clasificados por día o por hora).
class ColumnChart extends StatelessWidget {
  const ColumnChart({
    super.key,
    required this.items,
    this.height = 150,
    this.color,
    this.maxLabels = 7,
  });

  final List<ChartItem> items;
  final double height;
  final Color? color;

  /// Máximo de etiquetas en el eje X (para que no se encimen).
  final int maxLabels;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;
    final maxValue = items.fold<num>(0, (m, i) => math.max(m, i.value));
    final step = math.max(1, (items.length / maxLabels).ceil());
    final showValues = items.length <= 12;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.chartMax(Formatters.number(maxValue, t.localeName)),
          style: labelStyle,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final item in items)
                Expanded(
                  child: Tooltip(
                    message:
                        '${item.label}: ${Formatters.number(item.value, t.localeName)}',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (showValues && item.value > 0)
                            FittedBox(
                              child: Text(
                                Formatters.number(item.value, t.localeName),
                                style: labelStyle,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Container(
                            height: maxValue == 0
                                ? 2
                                : math.max(
                                    2,
                                    (height - 22) * (item.value / maxValue),
                                  ),
                            decoration: BoxDecoration(
                              color: item.color ?? barColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: i % step == 0
                    ? Text(
                        items[i].label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: labelStyle,
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ],
    );
  }
}

/// Barra de proporción con leyenda (ej. residuos por categoría).
class ProportionChart extends StatelessWidget {
  const ProportionChart({super.key, required this.items});

  final List<ChartItem> items;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total = items.fold<num>(0, (sum, i) => sum + i.value);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                for (final item in items)
                  if (item.value > 0)
                    Expanded(
                      flex: math.max(1, (item.value * 1000 / total).round()),
                      child: Container(
                        color: item.color ?? theme.colorScheme.primary,
                      ),
                    ),
                if (total == 0)
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color ?? theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.label, style: theme.textTheme.bodyMedium),
                ),
                Text(
                  Formatters.number(item.value, t.localeName),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 56,
                  child: Text(
                    Formatters.percent(
                      total == 0 ? 0 : item.value * 100 / total,
                      t.localeName,
                      decimals: 1,
                    ),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Punto de la gráfica de llenado.
class FillChartPoint {
  const FillChartPoint({
    required this.time,
    required this.percentage,
    this.isCollection = false,
  });

  final DateTime time;
  final double percentage;
  final bool isCollection;
}

/// Gráfica de llenado en escalones: el nivel sube con cada residuo y baja a
/// cero con cada recolección. La línea punteada es el umbral de alerta.
class FillLineChart extends StatelessWidget {
  const FillLineChart({
    super.key,
    required this.points,
    required this.threshold,
    this.height = 200,
  });

  final List<FillChartPoint> points;
  final double threshold;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _FillChartPainter(
              points: points,
              threshold: threshold,
              lineColor: scheme.primary,
              thresholdColor: const Color(0xFFE08B00),
              gridColor: scheme.outlineVariant,
              collectionColor: scheme.tertiary,
              surfaceColor: scheme.surface,
              labelStyle: labelStyle ?? const TextStyle(fontSize: 11),
              thresholdLabel: t.thresholdLine(
                Formatters.percent(threshold, t.localeName),
              ),
            ),
          ),
        ),
        if (points.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.dayMonth(
                    points.first.time.toLocal(),
                    t.localeName,
                  ),
                  style: labelStyle,
                ),
                Text(
                  Formatters.dayMonth(points.last.time.toLocal(), t.localeName),
                  style: labelStyle,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FillChartPainter extends CustomPainter {
  _FillChartPainter({
    required this.points,
    required this.threshold,
    required this.lineColor,
    required this.thresholdColor,
    required this.gridColor,
    required this.collectionColor,
    required this.surfaceColor,
    required this.labelStyle,
    required this.thresholdLabel,
  });

  final List<FillChartPoint> points;
  final double threshold;
  final Color lineColor;
  final Color thresholdColor;
  final Color gridColor;
  final Color collectionColor;
  final Color surfaceColor;
  final TextStyle labelStyle;
  final String thresholdLabel;

  static const double _left = 36;
  static const double _top = 8;
  static const double _bottom = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(
      _left,
      _top,
      size.width - 4,
      size.height - _bottom,
    );
    double y(double percentage) =>
        chart.bottom - chart.height * (percentage.clamp(0, 100) / 100);

    // Cuadrícula horizontal con su porcentaje.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final value in const [0, 25, 50, 75, 100]) {
      final dy = y(value.toDouble());
      canvas.drawLine(
        Offset(chart.left, dy),
        Offset(chart.right, dy),
        gridPaint,
      );
      _text(canvas, '$value%', Offset(0, dy - 7), maxWidth: _left - 6);
    }

    // Umbral de alerta (línea punteada).
    final thresholdY = y(threshold);
    final dashPaint = Paint()
      ..color = thresholdColor
      ..strokeWidth = 1.5;
    for (var x = chart.left; x < chart.right; x += 8) {
      canvas.drawLine(
        Offset(x, thresholdY),
        Offset(math.min(x + 4, chart.right), thresholdY),
        dashPaint,
      );
    }
    _text(
      canvas,
      thresholdLabel,
      Offset(chart.right - 120, thresholdY - 18),
      maxWidth: 120,
      color: thresholdColor,
      alignEnd: true,
      background: surfaceColor.withValues(alpha: 0.85),
    );

    if (points.isEmpty) return;

    final first = points.first.time.millisecondsSinceEpoch.toDouble();
    final last = points.last.time.millisecondsSinceEpoch.toDouble();
    final span = last - first;
    double x(DateTime time) {
      if (span <= 0) return chart.center.dx;
      final ms = time.millisecondsSinceEpoch.toDouble();
      return chart.left + chart.width * ((ms - first) / span);
    }

    // Línea en escalones y área sombreada debajo.
    final line = Path()
      ..moveTo(x(points.first.time), y(points.first.percentage));
    for (var i = 1; i < points.length; i++) {
      final px = x(points[i].time);
      line
        ..lineTo(px, y(points[i - 1].percentage))
        ..lineTo(px, y(points[i].percentage));
    }
    if (span <= 0) {
      line.lineTo(chart.center.dx + 1, y(points.last.percentage));
    }

    final area = Path.from(line)
      ..lineTo(x(points.last.time), chart.bottom)
      ..lineTo(x(points.first.time), chart.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.28),
            lineColor.withValues(alpha: 0.02),
          ],
        ).createShader(chart),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Recolecciones (círculos) y el punto actual.
    for (final point in points.where((p) => p.isCollection)) {
      final center = Offset(x(point.time), y(point.percentage));
      canvas.drawCircle(center, 5, Paint()..color = surfaceColor);
      canvas.drawCircle(
        center,
        5,
        Paint()
          ..color = collectionColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
    final current = Offset(x(points.last.time), y(points.last.percentage));
    canvas.drawCircle(current, 5.5, Paint()..color = lineColor);
    canvas.drawCircle(current, 2.5, Paint()..color = surfaceColor);
  }

  void _text(
    Canvas canvas,
    String text,
    Offset offset, {
    required double maxWidth,
    Color? color,
    bool alignEnd = false,
    Color? background,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: color == null
            ? labelStyle
            : labelStyle.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(minWidth: alignEnd ? maxWidth : 0, maxWidth: maxWidth);
    if (background != null) {
      // Fondo solo detrás del texto (no de todo el ancho reservado).
      final textWidth = painter.computeLineMetrics().fold<double>(
        0,
        (width, line) => math.max(width, line.width),
      );
      final left = alignEnd ? offset.dx + maxWidth - textWidth : offset.dx;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left - 4,
            offset.dy - 1,
            textWidth + 8,
            painter.height + 2,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = background,
      );
    }
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _FillChartPainter old) =>
      old.points != points ||
      old.threshold != threshold ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor ||
      old.labelStyle != labelStyle ||
      old.thresholdLabel != thresholdLabel;
}
