import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_detail_model.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/page_helpers.dart';
import 'package:parcial_2/presentation/shared/widgets/charts.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Evolución del llenado de un contenedor en los últimos 14 días.
/// La pueden ver todos los perfiles (para el Interesado es el "detalle").
class FillHistoryScreen extends ConsumerWidget {
  const FillHistoryScreen({super.key, required this.containerId});

  final int containerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final value = ref.watch(fillHistoryProvider(containerId));

    return Scaffold(
      appBar: AppBar(
        leading: pageBackButton(context, AppRoutes.containers),
        title: Text(t.titleFillHistory),
      ),
      body: AsyncView<FillHistoryModel>(
        value: value,
        onRetry: () => ref.invalidate(fillHistoryProvider(containerId)),
        skeleton: _HistoryBody(
          history: FillHistoryModel.placeholder(),
          skeleton: true,
        ),
        builder: (history) => RefreshIndicator(
          onRefresh: () => ref.refresh(fillHistoryProvider(containerId).future),
          child: _HistoryBody(history: history),
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.history, this.skeleton = false});

  final FillHistoryModel history;
  final bool skeleton;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final container = history.container;
    final locale = t.localeName;

    // Movimientos del más reciente al más antiguo (sin el punto "inicio").
    final movements = history.points.reversed
        .where((p) => p.event != 'inicio')
        .toList();

    return CustomScrollView(
      physics: skeleton
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList.list(
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CategoryAvatar(category: container.category),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  container.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${container.code} · ${container.locationName}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            status: container.status,
                            label: container.statusLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FillBar(
                        percentage: container.fillPercentage,
                        status: container.status,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${t.containerUnits(container.currentCount, container.capacityUnits)} · '
                        '${t.categoryName(container.category, fallback: container.categoryLabel)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ChartCard(
                title: t.titleFillHistory,
                subtitle: t.fillHistoryPeriod,
                child: history.points.length < 2
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text(t.fillHistoryEmpty)),
                      )
                    : FillLineChart(
                        threshold: history.threshold,
                        points: [
                          for (final point in history.points)
                            FillChartPoint(
                              time: point.time,
                              percentage: point.percentage,
                              isCollection: point.event == 'recoleccion',
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              SectionHeader(title: t.fillHistoryMovements),
            ],
          ),
        ),
        if (movements.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                t.fillHistoryEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.builder(
              itemCount: movements.length,
              itemBuilder: (context, index) =>
                  _MovementTile(point: movements[index], locale: locale),
            ),
          ),
      ],
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.point, required this.locale});

  final FillPointModel point;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (IconData icon, Color color) = switch (point.event) {
      'recoleccion' => (Icons.local_shipping_outlined, scheme.tertiary),
      'actual' => (Icons.radio_button_checked_rounded, scheme.primary),
      _ => (Icons.add_circle_outline_rounded, scheme.secondary),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.14),
        foregroundColor: color,
        child: Icon(icon, size: 20),
      ),
      title: Text(t.fillEventName(point.event)),
      subtitle: Text(Formatters.dateTime(point.time, locale)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formatters.percent(point.percentage, locale),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            t.unitsCollected(point.count),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
