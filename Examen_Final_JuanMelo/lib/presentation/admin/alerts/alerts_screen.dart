import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/container_actions.dart';
import 'package:parcial_2/presentation/admin/containers/widgets/container_card.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/widgets/async_view.dart';
import 'package:parcial_2/presentation/shared/widgets/state_views.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/data_provider.dart';
import 'package:parcial_2/providers/route_provider.dart';

/// Contenedores que superan su umbral de llenado (administrador y
/// recolector). El recolector puede pasarlos todos a su ruta de una vez.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  void _addAll(
    BuildContext context,
    WidgetRef ref,
    List<ContainerModel> items,
  ) {
    final t = AppLocalizations.of(context)!;
    final added = ref.read(routeProvider.notifier).addAll(items);
    AppAlerts.show(
      context,
      t.addedAllToRoute(added),
      type: added > 0 ? AlertType.success : AlertType.info,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final value = ref.watch(alertsProvider);
    final role = ref.watch(authProvider).user?.role;
    Future<void> refresh() => ref.refresh(alertsProvider.future);

    return AsyncView<List<ContainerModel>>(
      value: value,
      onRetry: () => ref.invalidate(alertsProvider),
      skeleton: const ContainerListSkeleton(count: 4),
      builder: (items) {
        if (items.isEmpty) {
          return RefreshableView(
            onRefresh: refresh,
            child: EmptyView(
              icon: Icons.task_alt_rounded,
              message: t.alertsEmpty,
            ),
          );
        }
        final full = items.where((c) => c.status == FillStatus.full).length;

        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Card(
                margin: EdgeInsets.zero,
                color: scheme.errorContainer.withValues(alpha: 0.6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_rounded,
                            color: scheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.alertsSummary(items.length),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: scheme.onErrorContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (full > 0) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Text(
                            '${t.statusFull}: $full',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      if (ContainerPermissions.usesRoute(role)) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _addAll(context, ref, items),
                          icon: const Icon(Icons.add_road_rounded),
                          label: Text(t.addAllToRoute),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final item in items) ...[
                ContainerCard(container: item),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}
