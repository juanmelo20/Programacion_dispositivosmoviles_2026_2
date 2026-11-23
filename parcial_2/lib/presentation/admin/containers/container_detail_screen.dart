import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/classification_model.dart';
import 'package:parcial_2/model/admin/container_detail_model.dart';
import 'package:parcial_2/presentation/admin/collections/widgets/collection_tile.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/container_actions.dart';
import 'package:parcial_2/presentation/shared/alerts/app_messages.dart';
import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/page_helpers.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/route_provider.dart';

/// Detalle de un contenedor (administrador y recolector).
class ContainerDetailScreen extends ConsumerWidget {
  const ContainerDetailScreen({super.key, required this.containerId});

  final int containerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final value = ref.watch(containerDetailProvider(containerId));
    final detail = value.value;

    return Scaffold(
      appBar: AppBar(
        leading: pageBackButton(context, AppRoutes.containers),
        title: Text(t.titleContainerDetail),
        actions: [
          IconButton(
            tooltip: t.menuFillHistory,
            icon: const Icon(Icons.show_chart_rounded),
            onPressed: detail == null
                ? null
                : () => ContainerActions.openHistory(context, detail.container),
          ),
        ],
      ),
      body: AsyncView<ContainerDetailModel>(
        value: value,
        onRetry: () => ref.invalidate(containerDetailProvider(containerId)),
        skeleton: _DetailBody(
          detail: ContainerDetailModel.placeholder(),
          skeleton: true,
        ),
        builder: (detail) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(containerDetailProvider(containerId).future),
          child: _DetailBody(detail: detail),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.detail, this.skeleton = false});

  final ContainerDetailModel detail;
  final bool skeleton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final role = ref.watch(authProvider).user?.role;
    final container = detail.container;
    final inRoute = ref.watch(
      routeProvider.select((route) => route.any((c) => c.id == container.id)),
    );
    final locale = t.localeName;
    final threshold = Formatters.percent(container.fillThreshold, locale);

    return ListView(
      physics: skeleton
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Encabezado: categoría, estado y medidor de llenado.
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryAvatar(category: container.category, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        container.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${container.code} · ${t.categoryName(container.category, fallback: container.categoryLabel)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          StatusChip(
                            status: container.status,
                            label: container.statusLabel,
                          ),
                          if (!container.isActive)
                            TagChip(
                              label: t.retiredBadge,
                              color: scheme.outline,
                              icon: Icons.archive_outlined,
                            ),
                          if (inRoute)
                            TagChip(
                              label: t.inRouteBadge,
                              color: scheme.tertiary,
                              icon: Icons.route_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    FillGauge(
                      percentage: container.fillPercentage,
                      status: container.status,
                      size: MediaQuery.sizeOf(context).width < 360 ? 88 : 112,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.containerUnits(
                        container.currentCount,
                        container.capacityUnits,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Acciones según el perfil.
        if (container.isActive && ContainerPermissions.canCollect(role))
          FilledButton.icon(
            onPressed: () =>
                ContainerActions.registerCollection(context, container),
            icon: const Icon(Icons.local_shipping_outlined),
            label: Text(t.emptyContainer),
          ),
        if (container.isActive && ContainerPermissions.usesRoute(role)) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                ContainerActions.toggleRoute(context, ref, container),
            icon: Icon(
              inRoute ? Icons.remove_road_rounded : Icons.add_road_rounded,
            ),
            label: Text(inRoute ? t.menuRemoveFromRoute : t.menuAddToRoute),
          ),
        ],
        const SizedBox(height: 16),

        // Datos del contenedor.
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.place_outlined,
                  label: t.fieldEcoPoint,
                  value: [
                    container.locationName,
                    if ((detail.locationDescription ?? '').isNotEmpty)
                      detail.locationDescription!,
                  ].join('\n'),
                ),
                InfoTile(
                  icon: Icons.inventory_2_outlined,
                  label: t.detailCapacity,
                  value: t.unitsCollected(container.capacityUnits),
                ),
                InfoTile(
                  icon: Icons.notifications_active_outlined,
                  label: t.detailThreshold,
                  value: container.usesGlobalThreshold
                      ? t.detailThresholdGlobal(threshold)
                      : threshold,
                ),
                InfoTile(
                  icon: Icons.event_available_outlined,
                  label: t.detailLastCollection,
                  value: container.lastCollectedAt == null
                      ? t.never
                      : Formatters.dateTime(container.lastCollectedAt, locale),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Indicadores de clasificación (misma altura las tres).
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Stat(
                  label: t.detailSinceCollection,
                  value: Formatters.number(
                    detail.classificationsSinceCollection,
                    locale,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: t.detailTotalClassifications,
                  value: Formatters.number(detail.totalClassifications, locale),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: t.detailLowConfidence,
                  value: Formatters.number(detail.lowConfidenceCount, locale),
                ),
              ),
            ],
          ),
        ),

        // Carrusel de las últimas clasificaciones (solo administrador).
        if (!detail.isSummary && detail.recentClassifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionHeader(title: t.detailRecentClassifications),
          _ClassificationsCarousel(items: detail.recentClassifications),
        ],

        const SizedBox(height: 16),
        SectionHeader(title: t.detailRecentCollections),
        if (detail.collections.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              t.detailNoCollections,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final collection in detail.collections) ...[
            CollectionTile(collection: collection, showContainer: false),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
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

/// Carrusel (PageView) con las fotos de los últimos residuos clasificados.
class _ClassificationsCarousel extends StatefulWidget {
  const _ClassificationsCarousel({required this.items});

  final List<ClassificationModel> items;

  @override
  State<_ClassificationsCarousel> createState() =>
      _ClassificationsCarouselState();
}

class _ClassificationsCarouselState extends State<_ClassificationsCarousel> {
  final _controller = PageController(viewportFraction: 0.82);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.items.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _ClassificationCard(item: widget.items[index]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_page + 1} / ${widget.items.length}',
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ClassificationCard extends StatelessWidget {
  const _ClassificationCard({required this.item});

  final ClassificationModel item;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final image = item.imageUrl;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: scheme.surfaceContainerHighest,
              child: image == null
                  ? Icon(
                      WasteColors.categoryIcon(item.predictedCategory),
                      size: 56,
                      color: scheme.outline,
                    )
                  : Image.network(
                      ApiConfig.mediaUrl(image),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: scheme.outline,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${t.categoryName(item.predictedCategory, fallback: item.predictedCategoryLabel, short: true)} · '
                  '${t.confidenceValue(Formatters.percent(item.confidence * 100, t.localeName))}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  Formatters.dateTime(item.createdAt, t.localeName),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
