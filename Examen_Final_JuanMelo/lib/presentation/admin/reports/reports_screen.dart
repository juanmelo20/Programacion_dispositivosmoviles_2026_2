import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/model/admin/report_model.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/eco_point_picker.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/charts.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Informes del campus (administrador e interesado): indicadores y gráficas
/// por periodo, categoría y punto ecológico.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  static const List<int> _periods = [7, 30, 90];

  int _days = 30;
  String? _category;
  int? _locationId;
  String? _locationName;

  Future<void> _pickEcoPoint() async {
    final choice = await showEcoPointPicker(context, selectedId: _locationId);
    if (choice == null || !mounted) return;
    setState(() {
      _locationId = choice.point?.id;
      _locationName = choice.point?.displayName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final query = (days: _days, category: _category, locationId: _locationId);
    final value = ref.watch(analyticsProvider(query));

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            children: [
              for (final days in _periods)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.periodDays(days)),
                    selected: _days == days,
                    onSelected: (_) => setState(() => _days = days),
                  ),
                ),
              const SizedBox(width: 4),
              ActionChip(
                avatar: Icon(
                  _locationId == null
                      ? Icons.place_outlined
                      : Icons.place_rounded,
                  size: 18,
                ),
                label: Text(
                  _locationId == null
                      ? t.allEcoPoints
                      : t.ecoPointFilter(_locationName ?? ''),
                ),
                onPressed: _pickEcoPoint,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            children: [
              for (final category in [null, ...WasteCategory.all])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category == null
                          ? t.allCategories
                          : t.categoryName(category, short: true),
                    ),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: AsyncView<AnalyticsModel>(
            value: value,
            onRetry: () => ref.invalidate(analyticsProvider(query)),
            skeleton: _ReportBody(
              report: AnalyticsModel.placeholder(),
              skeleton: true,
            ),
            builder: (report) => RefreshIndicator(
              onRefresh: () => ref.refresh(analyticsProvider(query).future),
              child: _ReportBody(report: report),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, this.skeleton = false});

  final AnalyticsModel report;
  final bool skeleton;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = t.localeName;
    final totals = report.totals;
    String n(num value) => Formatters.number(value, locale);

    Widget empty() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        t.reportEmptySection,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );

    return ListView(
      physics: skeleton
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          t.reportRange(
            Formatters.date(report.start, locale),
            Formatters.date(report.end, locale),
          ),
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ResponsiveGrid(
          children: [
            KpiCard(
              icon: Icons.auto_awesome_outlined,
              label: t.kpiClassifications,
              value: n(totals.classifications),
            ),
            KpiCard(
              icon: Icons.check_circle_outline_rounded,
              label: t.kpiValid,
              value: n(totals.valid),
              color: WasteColors.status(context, 'normal'),
            ),
            KpiCard(
              icon: Icons.help_outline_rounded,
              label: t.kpiLowConfidence,
              value: n(totals.lowConfidence),
              color: WasteColors.status(context, 'atencion'),
            ),
            KpiCard(
              icon: Icons.block_rounded,
              label: t.kpiRejected,
              value: n(totals.rejected),
              color: WasteColors.status(context, 'lleno'),
            ),
            KpiCard(
              icon: Icons.psychology_outlined,
              label: t.kpiAvgConfidence,
              value: Formatters.percent(
                totals.averageConfidence * 100,
                locale,
                decimals: 1,
              ),
              color: scheme.tertiary,
            ),
            KpiCard(
              icon: Icons.local_shipping_outlined,
              label: t.kpiCollections,
              value: n(totals.collections),
              color: scheme.tertiary,
            ),
            KpiCard(
              icon: Icons.inventory_2_outlined,
              label: t.kpiUnitsCollected,
              value: n(totals.unitsCollected),
              color: scheme.secondary,
            ),
            KpiCard(
              icon: Icons.today_outlined,
              label: t.kpiDailyAverage,
              value: Formatters.number(
                double.parse(totals.dailyAverage.toStringAsFixed(1)),
                locale,
              ),
              color: scheme.secondary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ChartCard(
          title: t.chartByCategory,
          child: report.byCategory.isEmpty
              ? empty()
              : ProportionChart(
                  items: [
                    for (final item in report.byCategory)
                      ChartItem(
                        label: t.categoryName(
                          item.category,
                          fallback: item.label,
                        ),
                        value: item.count,
                        color: WasteColors.categoryChart(item.category),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: t.chartDaily,
          child: report.daily.isEmpty
              ? empty()
              : ColumnChart(
                  items: [
                    for (final day in report.daily)
                      ChartItem(
                        label: Formatters.dayMonth(day.date, locale),
                        value: day.total,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: t.chartByLocation,
          child: report.byLocation.isEmpty
              ? empty()
              : HorizontalBarChart(
                  items: [
                    for (final item in report.byLocation)
                      ChartItem(label: item.locationName, value: item.total),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: t.chartByHour,
          child: report.byHour.every((h) => h.count == 0)
              ? empty()
              : ColumnChart(
                  color: scheme.tertiary,
                  maxLabels: 8,
                  items: [
                    for (final hour in _activeHours(report.byHour))
                      ChartItem(label: '${hour.hour}h', value: hour.count),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: t.chartTopContainers,
          child: report.topContainers.isEmpty
              ? empty()
              : Column(
                  children: [
                    for (final item in report.topContainers)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CategoryAvatar(
                          category: item.category,
                          size: 38,
                        ),
                        title: Text(
                          '${item.name} (${item.code})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(item.locationName),
                        trailing: Text(
                          n(item.count),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Recorta las horas sin actividad al inicio y al final del día.
  static List<HourCountModel> _activeHours(List<HourCountModel> hours) {
    final sorted = [...hours]..sort((a, b) => a.hour.compareTo(b.hour));
    final first = sorted.indexWhere((h) => h.count > 0);
    final last = sorted.lastIndexWhere((h) => h.count > 0);
    if (first < 0) return sorted;
    return sorted.sublist(first, last + 1);
  }
}
