import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/collection_model.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/presentation/admin/collections/widgets/collection_tile.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/providers/data_provider.dart';

/// Historial de recolecciones por periodo y categoría, agrupado por día.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  /// Periodos disponibles en días (1 = hoy).
  static const List<int> _periods = [1, 7, 30, 90];

  int _days = 7;
  String? _category;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final query = (days: _days, category: _category);
    final value = ref.watch(collectionsProvider(query));
    Future<void> refresh() => ref.refresh(collectionsProvider(query).future);

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
                    label: Text(days == 1 ? t.periodToday : t.periodDays(days)),
                    selected: _days == days,
                    onSelected: (_) => setState(() => _days = days),
                  ),
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
          child: AsyncView<List<CollectionModel>>(
            value: value,
            onRetry: () => ref.invalidate(collectionsProvider(query)),
            skeleton: _CollectionsList(
              items: [
                for (var i = 0; i < 6; i++) CollectionModel.placeholder(i),
              ],
              skeleton: true,
            ),
            builder: (items) {
              if (items.isEmpty) {
                return RefreshableView(
                  onRefresh: refresh,
                  child: EmptyView(
                    icon: Icons.inventory_2_outlined,
                    message: t.collectionsEmpty,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: refresh,
                child: _CollectionsList(items: items),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CollectionsList extends StatelessWidget {
  const _CollectionsList({required this.items, this.skeleton = false});

  final List<CollectionModel> items;
  final bool skeleton;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = t.localeName;
    final units = items.fold<int>(0, (sum, c) => sum + c.unitsCollected);

    // Agrupa por día local (la API entrega la más reciente primero).
    final groups = <DateTime, List<CollectionModel>>{};
    for (final item in items) {
      final local = item.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      groups.putIfAbsent(day, () => []).add(item);
    }

    return ListView(
      physics: skeleton
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          t.collectionsTotal(items.length, units),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              Formatters.weekdayDate(entry.key, locale),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final item in entry.value) ...[
            CollectionTile(collection: item),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}
