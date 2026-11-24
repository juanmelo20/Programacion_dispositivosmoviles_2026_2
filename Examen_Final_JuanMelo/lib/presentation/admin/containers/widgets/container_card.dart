import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/container_actions.dart';
import 'package:parcial_2/presentation/shared/widgets/waste_widgets.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/route_provider.dart';

enum _CardAction { detail, history, route, empty }

/// Tarjeta de un contenedor con su menú de opciones (card menu).
///
/// Las opciones del menú dependen del perfil: el administrador y el
/// recolector vacían el contenedor, el recolector arma su ruta y el
/// interesado solo consulta. Un contenedor no se crea, edita ni retira.
class ContainerCard extends ConsumerWidget {
  const ContainerCard({super.key, required this.container});

  final ContainerModel container;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final role = ref.watch(authProvider).user?.role;
    final inRoute = ref.watch(
      routeProvider.select((route) => route.any((c) => c.id == container.id)),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ContainerActions.open(context, role, container),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${container.code} · ${container.locationName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _menu(context, ref, t, role, inRoute),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FillBar(
                  percentage: container.fillPercentage,
                  status: container.status,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      t.containerUnits(
                        container.currentCount,
                        container.capacityUnits,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
    UserRole? role,
    bool inRoute,
  ) {
    final canSeeDetail = ContainerPermissions.canSeeDetail(role);
    final canCollect = ContainerPermissions.canCollect(role);
    final usesRoute = ContainerPermissions.usesRoute(role);

    return PopupMenuButton<_CardAction>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (action) {
        switch (action) {
          case _CardAction.detail:
            ContainerActions.open(context, role, container);
          case _CardAction.history:
            ContainerActions.openHistory(context, container);
          case _CardAction.route:
            ContainerActions.toggleRoute(context, ref, container);
          case _CardAction.empty:
            ContainerActions.registerCollection(context, container);
        }
      },
      itemBuilder: (context) => [
        if (canSeeDetail)
          _item(
            _CardAction.detail,
            Icons.visibility_outlined,
            t.menuViewDetail,
          ),
        _item(_CardAction.history, Icons.show_chart_rounded, t.menuFillHistory),
        if (usesRoute && container.isActive)
          inRoute
              ? _item(
                  _CardAction.route,
                  Icons.remove_road_rounded,
                  t.menuRemoveFromRoute,
                )
              : _item(
                  _CardAction.route,
                  Icons.add_road_rounded,
                  t.menuAddToRoute,
                ),
        if (canCollect && container.isActive) ...[
          const PopupMenuDivider(),
          _item(
            _CardAction.empty,
            Icons.local_shipping_outlined,
            t.emptyContainer,
          ),
        ],
      ],
    );
  }

  PopupMenuItem<_CardAction> _item(
    _CardAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<_CardAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Lista de tarjetas de ejemplo que se dibuja como esqueleto.
class ContainerListSkeleton extends StatelessWidget {
  const ContainerListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) =>
          ContainerCard(container: ContainerModel.placeholder(index)),
    );
  }
}
